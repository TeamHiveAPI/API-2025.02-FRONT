import 'dart:html' as html;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> downloadNota(String ne) async {
  final client = Supabase.instance.client;
  final bytes = await client.storage.from('notas-empenho').download('uploads/$ne.pdf');

  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', '$ne.pdf')
    ..click();
  html.Url.revokeObjectUrl(url);
}
