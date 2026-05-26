import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width = 160});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Text(
          'saku',
          style: TextStyle(
            color: SakuColors.blue700,
            fontSize: width * 0.28,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }
}
