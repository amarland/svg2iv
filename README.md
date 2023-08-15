# svg2iv ![Quality checks](https://github.com/amarland/svg2iv/actions/workflows/dart-ci.yml/badge.svg)

A Dart command-line tool and a Flutter desktop application (still in development) for generating Jetpack Compose `ImageVector`s from simple SVG and Android `VectorDrawable` files.

## Usage

Usage information can be obtained by passing the `--help|-h` option:

```
svg2iv.exe [options] <comma-separated source files/directories>

Options:
-o, --output=<file.kt> or <dir>    Either the path to the directory where you want the file(s) to be generated,
                                   or the path to the file in which all the ImageVectors will be generated
                                   if you wish to have them all declared in a single file.
                                   Will be created if it doesn't already exist and/or overwritten otherwise.
                                   When specifying a path which leads to a non-existent entity, this tool
                                   will assume it should lead to a directory unless it ends with '.kt'
                                   ​
-r, --receiver=<type>              The name of the receiver type for which the extension property(ies) will be
                                   generated. The type will NOT be created if it hasn't already been declared.
                                   For example, passing '--receiver=MyIcons ./fancy_icon.svg' will result
                                   in `MyIcons.FancyIcon` being generated.
                                   If not set, the generated property will be declared as a top-level property.
                                   ​
-q, --quiet                        Show error messages only.
-h, --help                         Displays this usage information.
```

### Examples

* Convert all SVG/`VectorDrawable` XML files located in the current directory (the generated files will be located in that same directory):
  > `svg2iv.exe` (that's it)

* Convert all SVG/`VectorDrawable` XML files located in your Downloads folder and place the generated files directly inside your project:
  > `svg2iv.exe -o ~/Projects/myproject/app/src/main/kotlin/com/example/myproject/icons/ ~/Downloads`

* Convert only the specified files:
  > `svg2iv.exe ~/Downloads/icon1.svg,~/Downloads/icon2.svg`

    In this instance, the files will be generated in the Downloads directory because both source files are located in this folder.\
    Had the source files been located in different directories, without providing a value for `--output`, the generated files would have been placed in the current working directory.

* Download an asset from the web, convert it and print the result to the terminal:

  Linux, with an SVG source:
  > `wget -qO- https://github.com/microsoft/fluentui-system-icons/raw/master/assets/Incognito/SVG/ic_fluent_incognito_24_regular.svg | svg2iv.exe -o -`

  Windows (PowerShell), with a VD source:
  > `(Invoke-WebRequest -Uri 'https://github.com/microsoft/fluentui-system-icons/raw/master/android/library/src/main/res/drawable/ic_fluent_incognito_24_regular.xml').Content | .\svg2iv.exe -o -`

  Executing the command above with the SVG source would generate the following code:
  ```kotlin
  import androidx.compose.ui.graphics.vector.*
  import androidx.compose.ui.unit.dp

  private var _icFluentIncognito24Regular: ImageVector? = null

  val IcFluentIncognito24Regular: ImageVector
      get() {
          if (_icFluentIncognito24Regular == null) {
              _icFluentIncognito24Regular = ImageVector.Builder(
                  defaultWidth = 24F.dp,
                  defaultHeight = 24F.dp,
                  viewportWidth = 24F,
                  viewportHeight = 24F,
              )
                  .path(
                      fill = SolidColor(Color(0xFF212121)),
                  ) {
                      moveTo(8.379F, 4.5F)
                      curveToRelative(-0.49F, 0F, -0.935F, 0.287F, -1.138F, 0.733F)
                      lineTo(6.183F, 7.56F)
                      curveTo(6.012F, 7.937F, 5.567F, 8.104F, 5.19F, 7.933F)
                      curveTo(4.813F, 7.76F, 4.646F, 7.317F, 4.817F, 6.94F)
                      lineToRelative(1.058F, -2.328F)
                      curveTo(6.322F, 3.63F, 7.301F, 3F, 8.38F, 3F)
                      horizontalLineToRelative(7.243F)
                      curveToRelative(1.078F, 0F, 2.057F, 0.63F, 2.503F, 1.612F)
                      lineToRelative(1.058F, 2.326F)
                      curveToRelative(0.171F, 0.378F, 0.005F, 0.822F, -0.372F, 0.994F)
                      curveToRelative(-0.377F, 0.171F, -0.822F, 0.004F, -0.994F, -0.373F)
                      lineTo(16.76F, 5.233F)
                      curveTo(16.557F, 4.786F, 16.113F, 4.5F, 15.622F, 4.5F)
                      horizontalLineTo(8.379F)
                      close()
                      // cut in the interest of space
                      moveTo(2.934F, 10.973F)
                      curveToRelative(5.13F, -1.297F, 13.003F, -1.297F, 18.132F, 0F)
                      curveToRelative(0.402F, 0.102F, 0.81F, -0.142F, 0.911F, -0.543F)
                      curveToRelative(0.102F, -0.402F, -0.141F, -0.81F, -0.543F, -0.911F)
                      curveToRelative(-5.37F, -1.359F, -13.497F, -1.359F, -18.868F, 0F)
                      curveToRelative(-0.401F, 0.101F, -0.644F, 0.51F, -0.543F, 0.91F)
                      curveToRelative(0.102F, 0.402F, 0.51F, 0.646F, 0.911F, 0.544F)
                      close()
                  }
                  .build()
              }
              return _icFluentIncognito24Regular!!
          }
  ```

___

🚧 **Under construction!** 🚧
