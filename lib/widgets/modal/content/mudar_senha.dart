import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _hasSixChars = false;
  bool _hasNumber = false;
  bool _hasUppercase = false;
  bool _hasSpecialChar = false;

  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswordOnType);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePasswordOnType);
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePasswordOnType() {
    if (_hasSubmitted) {
      setState(() {
        _hasSubmitted = false;
      });
    }

    final password = _passwordController.text;
    setState(() {
      _hasSixChars = password.length >= 6;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  Future<void> _updatePassword() async {
    setState(() {
      _hasSubmitted = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      showCustomSnackbar(
        context,
        'Erro: Usuário não encontrado.',
        isError: true,
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );

      await supabase
          .from('usuario')
          .update({'usr_primeiro_login': false})
          .eq('usr_auth_uid', userId);

      if (mounted) {
        showCustomSnackbar(context, 'Senha definida com sucesso!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          'Erro ao definir senha: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Para a sua segurança, crie uma nova senha de acesso.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          CustomTextFormField(
            upperLabel: 'Nova Senha',
            controller: _passwordController,
            obscureText: true,
            validator: (value) {
              if (!_hasSubmitted) {
                return null;
              }
              final isPasswordValid =
                  _hasSixChars &&
                  _hasUppercase &&
                  _hasNumber &&
                  _hasSpecialChar;
              if (isPasswordValid) {
                return null;
              }
              return 'Siga todas as condições abaixo';
            },
          ),

          const SizedBox(height: 16),
          _PasswordRequirement(
            text: 'Pelo menos 6 caracteres',
            isValid: _hasSixChars,
          ),
          const SizedBox(height: 4),
          _PasswordRequirement(
            text: 'Pelo menos 1 letra maiúscula',
            isValid: _hasUppercase,
          ),
          const SizedBox(height: 4),
          _PasswordRequirement(
            text: 'Pelo menos 1 número',
            isValid: _hasNumber,
          ),
          const SizedBox(height: 4),
          _PasswordRequirement(
            text: 'Pelo menos 1 caractere especial',
            isValid: _hasSpecialChar,
          ),

          const SizedBox(height: 24),

          CustomButton(
            text: 'Salvar Nova Senha',
            onPressed: _updatePassword,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isValid;

  const _PasswordRequirement({required this.text, required this.isValid});

  @override
  Widget build(BuildContext context) {
    final color = isValid ? successGreen : deleteRed;

    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: isValid ? successGreen : text60)),
      ],
    );
  }
}
