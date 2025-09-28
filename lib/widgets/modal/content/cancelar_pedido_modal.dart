import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/select.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';

Future<String?> showCancelarPedidoModal(
  BuildContext context, {
  required String idPedido,
}) {
  return showCustomBottomSheet<String?>(
    context: context,
    title: 'Cancelar Pedido',
    child: _CancelarPedidoModalContent(),
  );
}

class _CancelarPedidoModalContent extends StatefulWidget {
  const _CancelarPedidoModalContent();

  @override
  State<_CancelarPedidoModalContent> createState() =>
      _CancelarPedidoModalContentState();
}

class _CancelarPedidoModalContentState
    extends State<_CancelarPedidoModalContent> {
  final TextEditingController motivoController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? motivoSelecionado;

  @override
  void dispose() {
    motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selecione ou digite o motivo para cancelar o pedido. Esta ação não pode ser desfeita.',
            style: TextStyle(color: text60, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomDropdownInput<String>(
            hintText: 'Motivos Rápidos (opcional)',
            value: motivoSelecionado,
            items: const [
              DropdownOption(
                value: 'Solicitei o item errado',
                label: 'Solicitei o item errado',
              ),
              DropdownOption(
                value: 'Informei a quantidade errada',
                label: 'Informei a quantidade errada',
              ),
              DropdownOption(
                value: 'Não preciso mais do item',
                label: 'Não preciso mais do item',
              ),
              DropdownOption(
                value: 'Substituí o item por outro',
                label: 'Substituí o item por outro',
              ),
              DropdownOption(
                value: 'Consegui acesso ao item',
                label: 'Consegui acesso ao item',
              ),
              DropdownOption(
                value: 'Cancelado por ordem superior',
                label: 'Cancelado por ordem superior',
              ),
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(motivoController.text.trim());
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
  }
}
