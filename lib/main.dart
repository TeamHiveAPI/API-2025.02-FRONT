import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'app_routes.dart';

// 👇 importa os pacotes para .env e supabase
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Agora a main é async porque precisa "esperar" o carregamento do .env
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Carregar as variáveis do arquivo .env
  await dotenv.load(fileName: ".env");

  // 2️⃣ Inicializar o Supabase com as variáveis do .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '', // pega URL do .env
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '', // pega a anon key do .env
  );

  // 3️⃣ Agora sim roda o app normalmente
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _initialRoute = AppRoutes.login;

  @override
  void initState() {
    super.initState();
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _initialRoute = AppRoutes.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navegação com Roteador',

      // Seu tema continua igual
      theme: ThemeData(
        textTheme: GoogleFonts.ubuntuSansTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: brandBlue),
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 12.0,
          ),
          floatingLabelStyle: TextStyle(
            color: brandBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: text80,
          selectionColor: text80,
          selectionHandleColor: text80,
        ),
      ),

      // Rotas continuam iguais
      initialRoute: _initialRoute,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
