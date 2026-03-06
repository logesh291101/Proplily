import 'package:flutter/material.dart';

/// PropLilly logo widget - uses image asset with text fallback
class PropLillyLogo extends StatelessWidget {
  final double height;
  final bool white;

  const PropLillyLogo({
    super.key,
    this.height = 120,
    this.white = false,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/proplilly_logo.jfif',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _TextLogo(height: height, white: white),
    );
  }
}

class _TextLogo extends StatelessWidget {
  final double height;
  final bool white;

  const _TextLogo({required this.height, required this.white});

  @override
  Widget build(BuildContext context) {
    return Text(
      'PropLilly',
      style: TextStyle(
        fontSize: height * 0.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: white ? Colors.white : const Color(0xFF7C3AED),
      ),
    );
  }
}
