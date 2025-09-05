import 'package:flutter/material.dart' hide TextField;
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/core/extensions/getScreenSize.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/core/theme/global_styles.dart';
import 'package:sistema_almox/widgets/text_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text;
    final password = _passwordController.text;
    print("Recebido Email: $email e Senha: $password");
    Navigator.pushNamed(context, AppRoutes.home);
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
              child: Image.asset(
                'assets/bandeira-exercito.png',
                width: 64,
              ),
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

                    TextField(
                      label: 'E-mail',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16.0),

                    TextField(
                      label: 'Senha',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 32.0),

                    CustomButton(
                      text: 'Acessar o Sistema',
                      svgIconPath: 'assets/icons/arrow-right.svg',
                      widthPercent: 1.0,
                      onPressed: _login,
                    ),
                    const SizedBox(height: 16.0),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () {
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
        ],
      ),
    );
  }
}
