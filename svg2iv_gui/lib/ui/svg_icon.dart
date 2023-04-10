import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:svg2iv_common/extensions.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.assetName, {super.key});

  final String assetName;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = theme.size;
    return SvgPicture.asset(
      assetName,
      key: key,
      width: size,
      height: size,
      fit: BoxFit.scaleDown,
      colorFilter: theme.color?.let(
        (color) => ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
