import 'package:flutter/material.dart' hide TextField;
import 'package:flutter/services.dart';
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/core/extensions/getScreenSize.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/auth_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/core/theme/global_styles.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/debug_login_modal.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
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

  final bool _showDebugLoginButton = true;

  final Map<String, Map<String, String>> _debugLogins = {
    'Coronel': {'email': 'coronel@eb.mil.br', 'password': '123456'},
    'Tenente Estoque': {
      'email': 'tenenteestoque@eb.mil.br',
      'password': '123456',
    },
    'Tenente Farmácia': {
      'email': 'mariana@eb.mil.br',
      'password': '123456',
    },
    'Soldado Estoque': {
      'email': 'soldadoestoque@eb.mil.br',
      'password': '123456',
    },
    'Soldado Farmácia': {
      'email': 'soldadofarmacia@eb.mil.br',
      'password': '123456',
    },
    'Médico': {
      'email': 'medico@eb.mil.br',
      'password': 'Medico0!',
    },
  };

  void _showDebugLoginModal() {
    showCustomBottomSheet(
      context: context,
      title: 'Logins Rápidos',
      child: DebugLoginModal(
        logins: _debugLogins,
        onLoginSelected: (credentials) {
          _emailController.text = credentials['email']!;
          _passwordController.text = credentials['password']!;
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showCustomSnackbar(
        context,
        'Por favor, preencha o e-mail e a senha.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.login(email: email, password: password);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } on UserInactiveException catch (e) {
      if (mounted) {
        showCustomSnackbar(context, e.message, isError: true);
      }
    } on AuthException {
      if (mounted) {
        showCustomSnackbar(context, 'Email ou senha inválidos.', isError: true);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, e.toString(), isError: true);
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final screenHeight = context.screenHeight;

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
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

            if (_showDebugLoginButton)
              Positioned(
                top: 16,
                right: 20,
                child: SafeArea(
                  child: FloatingActionButton(
                    onPressed: _showDebugLoginModal,
                    backgroundColor: brandBlue,
                    child: const Icon(Icons.bug_report, color: Colors.white),
                  ),
                ),
              ),

            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: Image.asset('assets/bandeira-exercito.png', width: 120),
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

                      CustomTextFormField(
                        label: 'E-mail',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16.0),

                      CustomTextFormField(
                        label: 'Senha',
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 32.0),

                      CustomButton(
                        text: 'Acessar o Sistema',
                        customIcon: 'assets/icons/arrow-right.svg',
                        widthPercent: 1.0,
                        onPressed: _isLoading ? null : () => _login(),
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 16.0),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          onPressed: () {},
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
          ],
        ),
      ),
    );
  }
}
