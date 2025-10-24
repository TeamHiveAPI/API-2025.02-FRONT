import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadPdfPage extends StatefulWidget {
  const UploadPdfPage({super.key});

  static void navigateTo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UploadPdfPage()),
    );
  }

  @override
  State<UploadPdfPage> createState() => _UploadPdfPageState();
}

class _UploadPdfPageState extends State<UploadPdfPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool isLoading = false;
  String? uploadedUrl;

  Future<void> uploadPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum arquivo selecionado.')),
        );
        return;
      }

      final pickedFile = result.files.single;
      final fileName = pickedFile.name;

      if (!fileName.toLowerCase().endsWith('.pdf')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione apenas arquivos PDF.')),
        );
        return;
      }

      setState(() => isLoading = true);

      if (pickedFile.bytes != null) {

        await supabase.storage
            .from('notas-empenho')
            .uploadBinary(
              'uploads/$fileName',
              pickedFile.bytes!,
              fileOptions: const FileOptions(contentType: 'application/pdf'),
            );
      } else if (pickedFile.path != null) {

        final file = File(pickedFile.path!);
        await supabase.storage
            .from('notas-empenho')
            .upload('uploads/$fileName', file);
      } else {
        throw Exception('Arquivo inválido');
      }

      final publicUrl = supabase.storage
          .from('notas-empenho')
          .getPublicUrl('uploads/$fileName');

      setState(() {
        uploadedUrl = publicUrl;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload realizado com sucesso!')),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload de PDF')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: isLoading ? null : uploadPdf,
                icon: const Icon(Icons.upload_file),
                label: const Text('Selecionar e enviar PDF'),
              ),
              const SizedBox(height: 20),
              if (isLoading) const CircularProgressIndicator(),
              if (uploadedUrl != null) ...[
                const SizedBox(height: 20),
                const Text('Arquivo disponível em:'),
                SelectableText(
                  uploadedUrl!,
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
