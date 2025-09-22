import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}