import 'package:flutter/material.dart';

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;
  final double size;

  const IconBadge({
    super.key,
    required this.icon,
    required this.background,
    required this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: size * 0.5),
    );
  }
}
