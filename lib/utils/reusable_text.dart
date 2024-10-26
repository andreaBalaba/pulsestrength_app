import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReusableText extends StatelessWidget {
  const ReusableText({
    super.key,
    required this.text,
    this.size = 15,
    this.fontWeight = FontWeight.w500,
    this.color = Colors.black,
    this.align, // Added align parameter for text alignment
    this.maxLines,
    this.overflow,
    this.height,
  });

  final String text;
  final double? size;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign? align; // Declare align parameter
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: align, // Use the align parameter here
      style: GoogleFonts.poppins(
        fontSize: size,
        fontWeight: fontWeight,
        color: color,
        height: height,
      ),
    );
  }
}
