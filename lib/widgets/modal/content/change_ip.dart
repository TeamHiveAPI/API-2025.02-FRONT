import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';

class ConfigIpModal extends StatefulWidget {
  final String currentIp;

  final Function(String newIp) onSave;

  const ConfigIpModal({
    super.key,
    required this.currentIp,
    required this.onSave,
  });

  @override
  State<ConfigIpModal> createState() => _ConfigIpModalState();
}

class _ConfigIpModalState extends State<ConfigIpModal> {
  late TextEditingController _ipController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.currentIp);
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _handleSave() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final newIp = _ipController.text.trim();

      widget.onSave(newIp);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasIp = widget.currentIp.isNotEmpty;
    final String displayIp = hasIp ? widget.currentIp : "Não configurado";

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: coolGray,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.language, color: text40, size: 20),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'IP Atual: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: text40,
                        ),
                      ),
                      Text(
                        displayIp,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: text60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          CustomTextFormField(
            upperLabel: 'NOVO ENDEREÇO IP',
            keyboardType: TextInputType.phone,
            controller: _ipController,
            hintText: "Apenas números",
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira o endereço IP.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomButton(text: 'Salvar', onPressed: _handleSave, icon: Icons.add),
        ],
      ),
    );
  }
}
