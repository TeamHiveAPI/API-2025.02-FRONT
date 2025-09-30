import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
          throw Exception(
            'SUPABASE_URL ou SUPABASE_ANON_KEY não foram definidas no build.',
          );
        }
        await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
        print('Supabase configurado para Web!');
      } else {
        await dotenv.load(fileName: ".env");

        final url = dotenv.env['SUPABASE_URL'] ?? '';
        final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

        if (url.isEmpty || anonKey.isEmpty) {
          throw Exception(
            'SUPABASE_URL ou SUPABASE_ANON_KEY estão vazios no arquivo .env',
          );
        }

        await Supabase.initialize(url: url, anonKey: anonKey);
        print('Supabase configurado!');
      }
    } catch (e) {
      print('Erro na configuração do Supabase: $e');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
