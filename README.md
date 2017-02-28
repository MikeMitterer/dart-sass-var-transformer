# SASS Var Transformer
> Replaces vars in SCSS files with package path and compiles it to .css files

It depends on [dart-sass](https://github.com/sass/dart-sass), so there is no need to have [Sass](http://sass-lang.com/) installed.

## Usage

Add the following lines to your `pubspec.yaml`:

```yaml
dependencies:
  # Only for demonstration!!!!
  mdl: ^1.18.0

  # This is important
  sass_var_transformer: any
  
transformers:
  - di
  
  # And this
  - sass_var_transformer:
      # Converts @mdl to ../.pub-cache/hosted/pub.dartlang.org/mdl-x.xx.x/lib
      mdl: package:mdl
```

Assume you have `web/material.scss`:
```scss
@import "@mdl/assets/themes/deep_purple-pink/material-design-lite";
```

Add this line to your `index.html`:

```html
<head>
    <link rel="stylesheet" href="material.css">
</head>
```

If you run `pub serve`:

   - The Transformer reads the SCSS-File
   
   - @mdl will be replaced with the path to your local mdl-package  
   e.g. `@import "<your user>/.pub-cache/hosted/pub.dartlang.org/mdl-<version from pubspec>/lib/assets/themes/deep_purple-pink/material-design-lite";`
   
   - SCSS-File will be compiled to .CSS
   
Check out this sample: [GH MDL Text-Only](https://github.com/MikeMitterer/dart-sass-var-transformer/tree/master/samples/text_only)  
The sample uses a mixture between Global-Package-Style and Styles for local components!
   
### License 

    Copyright 2017 Michael Mitterer (office@mikemitterer.at),
    IT-Consulting and Development Limited, Austrian Branch

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
    either express or implied. See the License for the specific language
    governing permissions and limitations under the License.


If this plugin is helpful for you - please [(Circle)](http://gplus.mikemitterer.at/) me
or **star** this repo here on GitHub
   