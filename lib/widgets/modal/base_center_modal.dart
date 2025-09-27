import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';

Future<bool?> showCustomDialog({
  required BuildContext context,
  required String title,
  required Widget child,
  required String primaryButtonText,
  bool primaryButtonDanger = false,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,

    transitionDuration: const Duration(milliseconds: 300),

    pageBuilder: (context, animation, secondaryAnimation) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),

        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: text40,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(child: SingleChildScrollView(child: child)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: primaryButtonText,
                      danger: primaryButtonDanger,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Cancelar',
                      secondary: true,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },

    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      );

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: tween.animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        ),
      );
    },
  );
}
