import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sistema_almox/config/supabase_config.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/auth_gate.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      await SupabaseConfig.initialize();
      await UserService.instance.loadUserFromStorage();
      print('Inicialização na Splash Screen concluída.');
    } catch (e) {
      print('Erro durante a inicialização na Splash Screen: $e');
    }

    FlutterNativeSplash.remove();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
