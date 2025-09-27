import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/config/supabase_config.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseConfig.initialize();
    print('Supabase inicializado com sucesso');

    await UserService.instance.loadUserFromStorage();
  } catch (e) {
    print('Erro ao inicializar Supabase: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserService.instance),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final baseTextTheme = GoogleFonts.ubuntuSansTextTheme(
      Theme.of(context).textTheme,
    );

    const boldStyle = TextStyle(fontWeight: FontWeight.w700);

    final boldedTextTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.merge(boldStyle),
      displayMedium: baseTextTheme.displayMedium?.merge(boldStyle),
      displaySmall: baseTextTheme.displaySmall?.merge(boldStyle),
      headlineLarge: baseTextTheme.headlineLarge?.merge(boldStyle),
      headlineMedium: baseTextTheme.headlineMedium?.merge(boldStyle),
      headlineSmall: baseTextTheme.headlineSmall?.merge(boldStyle),
      titleLarge: baseTextTheme.titleLarge?.merge(boldStyle),
      titleMedium: baseTextTheme.titleMedium?.merge(boldStyle),
      titleSmall: baseTextTheme.titleSmall?.merge(boldStyle),
      bodyLarge: baseTextTheme.bodyLarge?.merge(boldStyle),
      bodyMedium: baseTextTheme.bodyMedium?.merge(boldStyle),
      bodySmall: baseTextTheme.bodySmall?.merge(boldStyle),
      labelLarge: baseTextTheme.labelLarge?.merge(boldStyle),
      labelMedium: baseTextTheme.labelMedium?.merge(boldStyle),
      labelSmall: baseTextTheme.labelSmall?.merge(boldStyle),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Almox',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: boldedTextTheme,
        colorScheme: ColorScheme.fromSeed(seedColor: brandBlue),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 12.0,
          ),
          labelStyle: const TextStyle(fontWeight: FontWeight.normal),
          floatingLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFFC4C4C4), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: brandBlue, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: deleteRed, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: deleteRed, width: 2.0),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: text80,
          selectionColor: text80,
          selectionHandleColor: text80,
        ),
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}