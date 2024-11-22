import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulsestrength/utils/global_variables.dart';

class ReusableButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final double? horizontal;
  final double vertical;
  final Color? color;
  final Color fontColor;
  final double size;
  final double borderRadius;
  final FontWeight weight;
  final double borderWidth;
  final bool removePadding;

  const ReusableButton({
    super.key,
    this.borderRadius = 0,
    required this.text,
    this.horizontal,
    this.vertical = 0.0,
    this.color,
    this.onPressed,
    this.size = 20,
    this.weight = FontWeight.w600,
    this.borderWidth = 2,
    this.fontColor = AppColors.pWhiteColor,
    this.removePadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: removePadding
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(horizontal: horizontal ?? 20.0, vertical: vertical),
      child: SizedBox(
        width: double.infinity,
        height: removePadding ? null : 60.0,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            backgroundColor: color ?? AppColors.pGreenColor,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: weight,
              fontSize: size,
              color: fontColor,
            ),
          ),
        ),
      ),
    );
  }
}
