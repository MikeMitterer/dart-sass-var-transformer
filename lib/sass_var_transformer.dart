import 'package:barback/barback.dart';
import 'package:sass/src/ast/sass.dart' as sass;
import 'package:sass/src/visitor/serialize.dart';
import 'package:sass/src/visitor/perform.dart';
import 'package:sass/src/io/vm.dart';
import 'package:path/path.dart' as p;
import 'package:package_resolver/package_resolver.dart';
import 'package:packages/packages.dart';

import 'dart:async';

/// Converts a var in scss-files to its defined package-path
///
///     @import "@mdl/assets/themes/deep_purple-pink/material-design-lite";
///
/// will be converted to
///
///     @import "<your user>/.pub-cache/hosted/pub.dartlang.org/mdl-<version from pubspec>/lib/assets/themes/deep_purple-pink/material-design-lite";
///     
class SassVarTransformer extends Transformer {
    final BarbackSettings _settings;

    final Map<String,String> _vars = new Map<String,String>();

    SassVarTransformer.asPlugin(this._settings) {
        _settings.configuration.forEach((final key,final value) {
            _vars.putIfAbsent(key, () => value);
        });
    }

    Future<bool> isPrimary(AssetId id) async =>
        id.extension == '.scss' || id.extension == '.sass';

    Future apply(Transform transform) async {
        var newAsset = new Asset.fromString(
            transform.primaryInput.id.changeExtension('.css'),
            _render(transform.primaryInput.id.path)
        );

        transform.consumePrimary();
        transform.addOutput(newAsset);
    }

    // - private -------------------------------------------------------------------------------------------------------

    /// Loads the Sass file at [path], replaces the given vars, converts it to CSS,
    /// and returns the result.
    ///
    /// If [color] is `true`, this will use terminal colors in warnings.
    ///
    /// If [packageResolver] is provided, it's used to resolve `package:` imports.
    /// Otherwise, they aren't supported. It takes a [SyncPackageResolver][] from
    /// the `package_resolver` package.
    ///
    /// [SyncPackageResolver]: https://www.dartdocs.org/documentation/package_resolver/latest/package_resolver/SyncPackageResolver-class.html
    ///
    /// Finally throws a [SassException] if conversion fails.
    String _render(String path, {bool color: false, SyncPackageResolver packageResolver}) {
        var contents = readFile(path);

        final Packages packages = new Packages();
        _vars.forEach((final String key, final String value) {
            if(value.startsWith("package:")) {
                final Package package = packages.resolvePackageUri( Uri.parse(value));
                contents = contents.replaceAll("@${key}",package.lib.path);
            } else {
                contents = contents.replaceAll("@${key}",value );
            }
        });

        var url = p.toUri(path);
        var sassTree = p.extension(path) == '.sass'
            ? new sass.Stylesheet.parseSass(contents, url: url, color: color)
            : new sass.Stylesheet.parseScss(contents, url: url, color: color);
        var cssTree = evaluate(sassTree, color: color, packageResolver: packageResolver);
        return toCss(cssTree);
    }

}
