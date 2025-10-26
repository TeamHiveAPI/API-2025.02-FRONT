import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> downloadNota(String ne) async {
  final client = Supabase.instance.client;
  final bytes = await client.storage.from('notas-empenho').download('uploads/$ne.pdf');

  if (bytes.isEmpty) {
    throw Exception('Arquivo não encontrado');
  }

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$ne.pdf');
  await file.writeAsBytes(bytes);
  await OpenFile.open(file.path);
}
