import 'package:sass/src/ast/sass.dart' as sass;
import 'package:sass/src/visitor/serialize.dart';
import 'package:sass/src/visitor/perform.dart';
import 'package:path/path.dart' as p;
import 'package:package_resolver/package_resolver.dart';

/// Called before sass renders the content - so you have a chance to change the content.
/// E.g replace vars or so
typedef String PreRenderer(final String content);

/// Converts [content] to CSS and returns the result.
/// This assumes that [content] is either in SCSS or CSS format
///
/// SASS needs [path] for its error messages, replaces the given vars, converts it to CSS,
/// and returns the result.
///
/// If [useColor] is `true`, this will use terminal colors in warnings.
///
/// If [packageResolver] is provided, it's used to resolve `package:` imports.
/// Otherwise, they aren't supported. It takes a [SyncPackageResolver][] from
/// the `package_resolver` package.
///
/// [SyncPackageResolver]: https://www.dartdocs.org/documentation/package_resolver/latest/package_resolver/SyncPackageResolver-class.html
///
/// Finally throws a [SassException] if conversion fails.
String sassRenderer(String contents, final String path, {
    final bool useColor: true,
    final SyncPackageResolver packageResolver,
    final PreRenderer preRenderer = _dummyPreRenderer }) {

    contents = preRenderer(contents);

    var url = p.toUri(path);
    var sassTree = p.extension(path) == '.sass'
        ? new sass.Stylesheet.parseSass(contents, url: url, color: useColor)
        : new sass.Stylesheet.parseScss(contents, url: url, color: useColor);
    var cssTree = evaluate(sassTree, color: useColor, packageResolver: packageResolver);
    return toCss(cssTree);
}

/// Dummy to avoid null
String _dummyPreRenderer(final String content) => content;