import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

Future<void> showCustomBottomSheet({
  required BuildContext context,
  required Widget child,
  required String title,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(
                  context,
                ).padding.bottom +
                20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: text40,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Flexible(child: SingleChildScrollView(child: child)),
            ],
          ),
        ),
      );
      },
  );
}

Future<void> showCustomDialog({
  required BuildContext context,
  required Widget child,
  required String title,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true, // fecha ao clicar fora
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: text40,
                ),
              ),
              const SizedBox(height: 16),
              
              // Conteúdo
              Flexible(child: SingleChildScrollView(child: child)),

              const SizedBox(height: 16),

              // Botão fechar
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
