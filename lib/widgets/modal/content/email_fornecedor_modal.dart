import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:sistema_almox/services/email_service.dart';
import 'package:sistema_almox/services/email_factory.dart';

class EmailFornecedorModal extends StatefulWidget {
  final String fornecedorEmail;
  const EmailFornecedorModal({super.key, required this.fornecedorEmail});

  @override
  State<EmailFornecedorModal> createState() => _EmailFornecedorModalState();
}

class _EmailFornecedorModalState extends State<EmailFornecedorModal> {
  final _diasController = TextEditingController(text: '7');
  final _assuntoController = TextEditingController(text: 'Notificação de Prazo');
  final _mensagemController = TextEditingController(text: 'Você tem {{dias}} dias para concluir o procedimento.');
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _diasController.dispose();
    _assuntoController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final dias = int.tryParse(_diasController.text.trim()) ?? 0;
    if (dias <= 0) {
      showCustomSnackbar(context, 'Dias inválidos.', isError: true);
      return;
    }
    setState(() => _sending = true);
    try {
      // Armazene assunto/corpo real em tabela de templates no backend. Aqui embrulhamos payload.
      final msg = EmailFactory.prazoDias(
        toEmail: widget.fornecedorEmail,
        dias: dias,
        assunto: _assuntoController.text.trim(),
        mensagemRaw: _mensagemController.text.trim(),
      );
      await EmailService.instance.dispatch(msg);
      if (mounted) {
        _sent = true;
        showCustomSnackbar(context, 'E-mail enfileirado para envio.');
      }
    } catch (e) {
      if (mounted) showCustomSnackbar(context, 'Falha: $e', isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Fornecedor: ${widget.fornecedorEmail}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          CustomTextFormField(label: 'Dias de prazo', controller: _diasController, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          CustomTextFormField(label: 'Assunto', controller: _assuntoController),
          const SizedBox(height: 12),
          CustomTextFormField(label: 'Mensagem (suporta {{dias}})', controller: _mensagemController, textarea: true),
          const SizedBox(height: 16),
          if (!_sent)
            CustomButton(
              text: _sending ? 'Enviando...' : 'Enviar E-mail',
              onPressed: _sending ? null : _send,
              isLoading: _sending,
            )
          else
            CustomButton(
              text: 'Fechar',
              onPressed: () => Navigator.pop(context, true),
            ),
        ],
      ),
    );
  }
}
