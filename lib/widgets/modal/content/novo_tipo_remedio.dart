import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/custom_radio_button.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/modal/base_modal.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

void showAddMedicineType(BuildContext pageContext) {
  showCustomBottomSheet(
    context: pageContext,
    title: 'Cadastrar Novo Tipo',
    child: _CadastrarTipoForm(scaffoldContext: pageContext),
  );
}

class _CadastrarTipoForm extends StatefulWidget {
  final BuildContext scaffoldContext;

  const _CadastrarTipoForm({required this.scaffoldContext});

  @override
  State<_CadastrarTipoForm> createState() => _CadastrarTipoFormState();
}

class _CadastrarTipoFormState extends State<_CadastrarTipoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  bool _isControlado = true;

void _submitForm() {
  FocusManager.instance.primaryFocus?.unfocus();

  if (_formKey.currentState!.validate()) {
    final nome = _nomeController.text.trim();
    final isControlado = _isControlado;
    print('Medicamento cadastrado: $nome, Controlado: $isControlado');

    showCustomSnackbar(
      widget.scaffoldContext,
      'Tipo de medicamento cadastrado com sucesso!',
    );

    Navigator.pop(context);
  }
}

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            label: 'Nome do Medicamento',
            controller: _nomeController,
            keyboardType: TextInputType.text,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe o nome do medicamento.';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'É controlado?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: text40,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CustomRadioButton<bool>(
                value: true,
                groupValue: _isControlado,
                label: 'Sim',
                onChanged: (value) {
                  setState(() {
                    _isControlado = value!;
                  });
                },
              ),
              const SizedBox(width: 24),
              CustomRadioButton<bool>(
                value: false,
                groupValue: _isControlado,
                label: 'Não',
                onChanged: (value) {
                  setState(() {
                    _isControlado = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Cadastrar',
            widthPercent: 1.0,
            onPressed: _submitForm,
          ),
        ],
      ),
    );
  }
}
