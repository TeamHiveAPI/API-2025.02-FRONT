import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_almox/widgets/modal/base_center_modal.dart';

Future<void> showTemporaryPasswordModal(BuildContext context, String password) {
  return showCustomDialog(
    context: context,
    title: 'Conta criada com sucesso!',
    primaryButtonText: 'Entendi',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'A senha temporária da nova conta é:',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SelectableText(
                password,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Copiar Senha',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: password));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Senha copiada para a área de transferência!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Text('Aviso Importante', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        const Text(
          'Copie esta senha na sua área de transferência e guarde-a em um lugar seguro. Se a senha for perdida antes do primeiro acesso, será necessário redefinir a senha da conta.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
