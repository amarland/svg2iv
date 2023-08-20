import 'package:flutter/material.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:vector_graphics/vector_graphics.dart';

class VectorGraphicIcon extends StatefulWidget {
  const VectorGraphicIcon(this.assetName, {super.key, this.packageName});

  final String assetName;
  final String? packageName;

  @override
  State<StatefulWidget> createState() => _VectorGraphicIconState();
}

class _VectorGraphicIconState extends State<VectorGraphicIcon> {
  late BytesLoader _loader;

  @override
  void initState() {
    super.initState();
    _resetLoader();
  }

  @override
  void didUpdateWidget(VectorGraphicIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetLoader();
  }

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = theme.size;
    return VectorGraphic(
      loader: _loader,
      width: size,
      height: size,
      fit: BoxFit.scaleDown,
      colorFilter: theme.color?.let(
        (color) => ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }

  void _resetLoader() {
    _loader = AssetBytesLoader(
      widget.assetName,
      packageName: widget.packageName,
    );
  }
}
