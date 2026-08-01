import 'package:flutter/material.dart';

/// SprayLog brand mark — a simple "SL" tile in the spirit of the Flutter
/// logo: white italic letters on a sky-blue rounded square.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 36});

  final double size;

  static const skyBlue = Color(0xFF4FC3F7);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: skyBlue,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      alignment: Alignment.center,
      child: Text(
        'SL',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          height: 1,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
