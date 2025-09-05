import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistema_almox/core/theme/colors.dart';

extension TextStyleExtension on BuildContext {

  TextStyle get titleLarge => GoogleFonts.ubuntuSans(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: text40
  );

  TextStyle get textTitle =>
      GoogleFonts.ubuntuSans(fontWeight: FontWeight.w600, fontSize: 20);
}
