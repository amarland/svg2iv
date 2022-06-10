import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.assetName, {Key? key}) : super(key: key);

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
      color: theme.color,
    );
  }
}
