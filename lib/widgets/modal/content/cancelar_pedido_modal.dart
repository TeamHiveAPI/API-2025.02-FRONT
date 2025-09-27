import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/select.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

Future<void> showCancelarPedidoModal(
  BuildContext context, {
  required String idPedido,
  required Future<void> Function(String idPedido, String motivo) cancelarPedido,
}) async {
  final TextEditingController motivoController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? motivoSelecionado;

  await showCustomBottomSheet(
    context: context,
    title: 'Cancelar Pedido',
    child: StatefulBuilder(
      builder: (context, setState) {

        return Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Digite o motivo abaixo para cancelar o pedido. Esta ação não pode ser desfeita.',
                style: TextStyle(color: text60, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              CustomDropdownInput<String>(
                hintText: 'Motivos Rápidos (opcional)',
                value: motivoSelecionado,
                items: const [
                  DropdownOption(value: 'Solicitei o item errado', label: 'Solicitei o item errado'),
                  DropdownOption(value: 'Informei a quantidade errada', label: 'Informei a quantidade errada'),
                  DropdownOption(value: 'Não preciso mais do item', label: 'Não preciso mais do item'),
                  DropdownOption(value: 'Substituí o item que precisava por outro', label: 'Substituí o item que precisava por outro'),
                  DropdownOption(value: 'Consegui acesso ao item', label: 'Consegui acesso ao item'),
                  DropdownOption(value: 'Cancelado por ordem superior', label: 'Cancelado por ordem superior'),
                ],
                onChanged: (value) {
                  setState(() => motivoSelecionado = value);
                  motivoController.text = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              CustomTextFormField(
                controller: motivoController,
                label: "Motivo",
                hintText: 'Digite aqui',
                textarea: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo Obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomButton(
                text: 'Confirmar cancelamento',
                danger: true,
                onPressed: () async {
                  setState(() {});

                  if (!formKey.currentState!.validate()) return;

                  try {
                    await cancelarPedido(idPedido, motivoController.text.trim());
                    showCustomSnackbar(context, 'Pedido cancelado com sucesso!');
                    Navigator.of(context).pop();
                  } catch (e) {
                    showCustomSnackbar(
                      context,
                      'Erro ao cancelar pedido: $e',
                      isError: true,
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Voltar',
                secondary: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}
