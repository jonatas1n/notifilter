import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotifilterLogo extends StatelessWidget {
  const NotifilterLogo({
    super.key,
    this.size = 48,
    this.showLabel = false,
  });

  final double size;
  final bool showLabel;

  static const String _assetPath = 'assets/icon/notifilter_logo.svg';

  @override
  Widget build(BuildContext context) {
    final mark = SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
      semanticsLabel: 'Notifilter',
    );

    if (!showLabel) {
      return mark;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.25),
        Text(
          'Notifilter',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}
