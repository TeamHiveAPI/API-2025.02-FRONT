import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/modal/base_center_modal.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';

Future<void> showTemporaryPasswordModal(BuildContext context, String password) {
  return showCustomDialog(
    context: context,
    title: 'Conta criada com sucesso!',
    primaryButtonText: 'Entendido',
    oneButtonOnly: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'A senha temporária da nova conta é:',
          textAlign: TextAlign.center,
          style: TextStyle(color: text60),
        ),

        const SizedBox(height: 16),

        DetailItemCard(
          label: "",
          value: password,
          copyButton: true,
          hideLabel: true,
        ),

        const SizedBox(height: 16),

        const Text(
          'AVISO IMPORTANTE',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: text40, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 12),

        const Text(
          'Guarde esta senha em um lugar seguro. Se a senha for perdida antes do primeiro acesso, será necessário redefinir a senha da conta.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: text60),
        ),
      ],
    ),
  );
}
