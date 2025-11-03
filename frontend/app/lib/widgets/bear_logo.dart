import 'package:flutter/material.dart';

class BearLogo extends StatelessWidget {
  final double width;
  final double height;

  const BearLogo({super.key, this.width = 80, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/pixel_bear.png',
      width: width,
      height: height,
      filterQuality: FilterQuality.none,
    );
  }
}