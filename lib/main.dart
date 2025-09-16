import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Almox',

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.ubuntuSansTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: brandBlue),

        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 12.0,
          ),
          
          labelStyle: const TextStyle(fontWeight: FontWeight.normal),
          floatingLabelStyle: const TextStyle(fontWeight: FontWeight.w600),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: Color(0xFFC4C4C4),
              width: 1,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: brandBlue,
              width: 2.0,
            ),
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
