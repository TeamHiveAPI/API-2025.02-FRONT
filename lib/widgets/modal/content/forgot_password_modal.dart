import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:sistema_almox/services/email_service.dart';
import 'package:sistema_almox/services/email_factory.dart';

class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({super.key});

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _done = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showCustomSnackbar(context, 'Informe o e-mail.', isError: true);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
  final msg = EmailFactory.resetPassword(email);
  await EmailService.instance.dispatch(msg);
      if (mounted) {
        setState(() => _done = true);
        showCustomSnackbar(context, 'Se o e-mail existir, uma mensagem foi enviada.');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, 'Falha: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_done) ...[
          CustomTextFormField(
            label: 'E-mail cadastrado',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: _isSubmitting ? 'Enviando...' : 'Enviar link de recuperação',
            onPressed: _isSubmitting ? null : _submit,
            isLoading: _isSubmitting,
          ),
        ] else ...[
          const Icon(Icons.check_circle, color: Colors.green, size: 42),
          const SizedBox(height: 12),
            const Text(
            'Verifique sua caixa de entrada. Caso não veja, cheque o spam.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Fechar',
            onPressed: () => Navigator.pop(context, true),
          ),
        ]
      ],
    );
  }
}
