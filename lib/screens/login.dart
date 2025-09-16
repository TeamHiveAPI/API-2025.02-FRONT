import 'package:flutter/material.dart' hide TextField;
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/core/extensions/getScreenSize.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/core/theme/global_styles.dart';
import 'package:sistema_almox/widgets/text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Informe e-mail e senha';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _performLogin(email, password);
  }

  Future<void> _performLogin(String email, String password) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final session = response.session;
      if (session != null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Falha no login. Verifique suas credenciais.';
          });
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro inesperado. Tente novamente.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: screenHeight * 0.7,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/ilustracao-login.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Image.asset('assets/bandeira-exercito.png', width: 64),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LOGIN',
                      textAlign: TextAlign.center,
                      style: context.titleLarge,
                    ),
                    const SizedBox(height: 32.0),

                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],

                    TextField(
                      label: 'E-mail',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16.0),

                    TextField(
                      label: 'Senha',
                      controller: _passwordController,
                      obscureText: true,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 32.0),

                    CustomButton(
                      text: _isLoading ? 'Entrando...' : 'Acessar o Sistema',
                      svgIconPath: 'assets/icons/arrow-right.svg',
                      widthPercent: 1.0,
                      onPressed: _isLoading ? null : _login,
                    ),
                    const SizedBox(height: 16.0),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                final supabase = Supabase.instance.client;
                                if (supabase.auth.currentSession != null) {
                                  if (!mounted) return;
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.home,
                                  );
                                } else {
                                  setState(() {
                                    _errorMessage =
                                        'Sem sessão ativa. Informe e-mail e senha.';
                                  });
                                }
                              },
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all<Color>(
                            brandBlue,
                          ),

                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),

                          elevation: WidgetStateProperty.all(0),
                        ),
                        child: const Text(
                          'Esqueci minha Senha',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isLoading) Container(color: Colors.black.withOpacity(0.04)),
        ],
      ),
    );
  }
}
