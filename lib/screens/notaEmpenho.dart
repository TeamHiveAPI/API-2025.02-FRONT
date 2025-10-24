import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sistema_almox/services/subirEmpenho.dart';
import 'package:sistema_almox/services/criar_empenho.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'notaEmpenhoFormsScreen.dart';

class NotaEmpenhoScreen extends StatefulWidget {
  const NotaEmpenhoScreen({super.key});

  @override
  State<NotaEmpenhoScreen> createState() => _NotaEmpenhoScreenState();
}

class _NotaEmpenhoScreenState extends State<NotaEmpenhoScreen> {
  final _notaService = NotaEmpenhoService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _notas = [];

  @override
  void initState() {
    super.initState();
    _fetchNotas();
  }

  Future<void> _fetchNotas() async {
    final data = await _notaService.fetchNotas();
    setState(() {
      _notas = data;
    });
  }

  void _handleSearch(String query) {
    setState(() => _searchQuery = query);
  }

  Future<void> _confirmDelete(BuildContext context, int id, String nome) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Nota de Empenho'),
        content: Text('Tem certeza que deseja excluir "$nome"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notaService.deleteNota(id);
              _fetchNotas();
              showCustomSnackbar(context, 'Nota excluída com sucesso!');
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 📄 Gera o PDF com os dados da nota
  Future<void> _downloadDocument(BuildContext context, Map<String, dynamic> nota) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('NOTA DE EMPENHO',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 16),
                  _buildLine('NE', nota['NE']),
                  _buildLine('Data', nota['data']),
                  _buildLine('Favorecido', nota['favorecido']),
                  _buildLine('Processo Adm', nota['processo_adm']),
                  _buildLine('Material Recebido', nota['material_recebido']),
                  _buildLine('NF Entregue no Almox', nota['nf_entregue_no_almox']),
                  _buildLine('Justificativa de Atraso', nota['justificativa_atraso']),
                  _buildLine('Enviado para Liquidar', nota['enviado_para_liquidar']),
                  _buildLine('Item', nota['item']),
                  _buildLine('Dias', nota['dias']?.toString()),
                  _buildLine('Saldo', nota['saldo']?.toString()),
                  pw.SizedBox(height: 24),
                  pw.Divider(),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('Gerado automaticamente em ${DateTime.now()}',
                        style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final Uint8List pdfBytes = await pdf.save();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'NE_${nota['NE'] ?? 'sem_NE'}.pdf',
      );

      showCustomSnackbar(context, 'PDF gerado com sucesso!');
    } catch (e) {
      showCustomSnackbar(context, 'Erro ao gerar PDF: $e', isError: true);
    }
  }

  pw.Widget _buildLine(String title, String? value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        '$title: ${value ?? '-'}',
        style: const pw.TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotas = _notas.where((n) {
      final ne = n['NE']?.toString().toLowerCase() ?? '';
      return ne.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Text('Listagem de Notas de Empenho',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              GenericSearchInput(controller: _searchController, onSearchChanged: _handleSearch),
              const SizedBox(height: 20),

              DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(label: Text('Item')),
                  DataColumn(label: Text('NE')),
                  DataColumn(label: Text('Favorecido')),
                  DataColumn(label: Text('Data')),
                  DataColumn(label: Text('Ações')),
                ],
                rows: filteredNotas.map((nota) {
                  return DataRow(cells: [
                    DataCell(Text(nota['item'] ?? '')),
                    DataCell(Text(nota['NE'] ?? '')),
                    DataCell(Text(nota['favorecido'] ?? '')),
                    DataCell(Text(nota['data'] ?? '')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotaEmpenhoFormScreen(nota: nota),
                              ),
                            ).then((_) => _fetchNotas());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, nota['id'], nota['NE']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.orange),
                          onPressed: () => _downloadDocument(context, nota),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
                            CustomButton(
                text: 'Nova Nota de Empenho',
                icon: Icons.add,
                widthPercent: 1.0,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotaEmpenhoFormScreen()),
                  ).then((_) => _fetchNotas());
                },
              ),
              const SizedBox(height: 16),
            CustomButton(
            text: 'Adicionar empenho',
               icon: Icons.add,
               widthPercent: 1.0,
               onPressed: () {
               UploadPdfPage.navigateTo(context);
               },
            ),            ],
          ),
        ),
      ),
    );
  }
}
