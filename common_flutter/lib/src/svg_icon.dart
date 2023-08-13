import 'package:flutter/material.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:vector_graphics/vector_graphics.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.assetName, {super.key, this.packageName});

  final String assetName;
  final String? packageName;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = theme.size;
    return VectorGraphic(
      loader: AssetBytesLoader(assetName, packageName: packageName),
      width: size,
      height: size,
      fit: BoxFit.scaleDown,
      colorFilter: theme.color?.let(
        (color) => ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
