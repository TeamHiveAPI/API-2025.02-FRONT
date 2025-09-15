import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FooterComponent extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const FooterComponent({
    super.key,
    required this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF107A15),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          minimumSize: const Size(120, 56), 
        ),
        onPressed: onButtonPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6), 
            SvgPicture.asset(
              'assets/icons/addicon.svg',
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}