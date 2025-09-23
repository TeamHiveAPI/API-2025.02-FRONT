import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Para Flutter Web, usar valores hardcoded temporariamente
        await Supabase.initialize(
          url: 'https://jlykzxqlscmbduraczcy.supabase.co', // Substitua pela sua URL
          anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpseWt6eHFsc2NtYmR1cmFjemN5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczMzMzODIsImV4cCI6MjA3MjkwOTM4Mn0.-pdPGhdMvS_OGMj1BFoNgfWiHmF4oXoiWLBqAptUzCI', // Substitua pela sua chave
        );
        print('Supabase configurado para Web');
      } else {
        // Para mobile/desktop, usar arquivo .env
        await dotenv.load(fileName: ".env");

        final url = dotenv.env['SUPABASE_URL'] ?? '';
        final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

        if (url.isEmpty || anonKey.isEmpty) {
          throw Exception(
            'SUPABASE_URL ou SUPABASE_ANON_KEY estão vazios no arquivo .env',
          );
        }

        await Supabase.initialize(url: url, anonKey: anonKey);
        print('Supabase configurado com URL: $url');
      }
    } catch (e) {
      print('Erro na configuração do Supabase: $e');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
