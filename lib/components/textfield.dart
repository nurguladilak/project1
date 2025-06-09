import 'package:flutter/material.dart';
import 'package:social_media/components/color.dart';

class TextField1 extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final double? width;
  final double? height;

  const TextField1({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        width: width,
        height: height,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: AppColors.kiwi, fontSize: 15),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: const BorderSide(color: AppColors.indigo, width: 1.3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: const BorderSide(
                color: AppColors.coffee1,
                width: 1.0,
              ),
            ),
            fillColor: AppColors.star,
            filled: true,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.color13,
              fontFamily: 'Mania',
            ),
          ),
        ),
      ),
    );
  }
}
