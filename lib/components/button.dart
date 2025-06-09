import 'package:flutter/material.dart';
import 'package:social_media/components/color.dart';

class Button1 extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final String? fontFamily;

  const Button1({
    super.key,
    required this.onTap,
    required this.text,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.lemon,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor ?? AppColors.star,
              fontFamily: fontFamily ?? 'Platinum',
              fontSize: fontSize ?? 14,
            ),
          ),
        ),
      ),
    );
  }
}
