import 'package:flutter/material.dart';
import 'package:sistema_almox/services/subirEmpenho.dart';
import 'package:sistema_almox/services/criar_empenho.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'notaEmpenhoFormsScreen.dart';
import 'package:sistema_almox/services/donwload_NE/download_nota.dart';
import 'package:sistema_almox/services/disparoEmail.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ Import necessário

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
              await _notaService.deleteNota(id, nome);
              _fetchNotas();
              showCustomSnackbar(context, 'Nota excluída com sucesso!');
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<String?> _askForEmail(BuildContext context, String? initial) {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Digite o e-mail do destinatário'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'destinatario@exemplo.com'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotas = _notas.where((n) {
      final query = _searchQuery.toLowerCase();
      final ne = n['NE']?.toString().toLowerCase() ?? '';
      final item = n['item']?.toString().toLowerCase() ?? '';
      final favorecido = n['favorecido']?.toString().toLowerCase() ?? '';
      final saldo = n['saldo']?.toString().toLowerCase() ?? '';
      final secao = n['secao']?.toString().toLowerCase() ?? '';

      return ne.contains(query) ||
          item.contains(query) ||
          favorecido.contains(query) ||
          saldo.contains(query) ||
          secao.contains(query);
    }).toList();


    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                  columns: const [
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('NE')),
                    DataColumn(label: Text('Favorecido')),
                    DataColumn(label: Text('Seção')),
                    DataColumn(label: Text('saldo')),
                    DataColumn(label: Text('Ações')),
                  ],
                  rows: filteredNotas.map((nota) {
                    return DataRow(cells: [
                      DataCell(SizedBox(
                        width: 120,
                        child: Text(nota['item'] ?? '', overflow: TextOverflow.ellipsis),
                      )),
                      DataCell(Text(nota['NE'] ?? '')),
                      DataCell(SizedBox(
                        width: 150,
                        child: Text(nota['favorecido'] ?? '', overflow: TextOverflow.ellipsis),
                      )),
                      DataCell(SizedBox(
                        width: 120,
                        child: Text(nota['secao'] ?? '', overflow: TextOverflow.ellipsis),
                      )),
                      DataCell(Text(nota['saldo']?.toString() ?? '')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NotaEmpenhoFormScreen(nota: nota),
                                  ),
                                ).then((reload) {
                                  if (reload == true) _fetchNotas();
                                });
                              },
                            ),

                            /// ✅ Botão para enviar email com PDF
                            IconButton(
                              icon: const Icon(Icons.email, color: Colors.green),
                              onPressed: () async {
                                try {
                                  final supabase = Supabase.instance.client;

                                  // monta caminho no bucket, ajuste se seu bucket/prefix for diferente
                                  final pdfPath = 'notas-empenho/uploads/${nota['NE']}.pdf';

                                  // gera URL pública (retorna String)
                                  final pdfUrl = supabase.storage.from('notas-empenho').getPublicUrl(pdfPath);

                                  // tenta obter email a partir da nota (campo 'email'), se presente
                                  String? destinatario = nota['email']?.toString();

                                  // se não houver destinatario, pede para o usuário digitar
                                  if (destinatario == null || destinatario.trim().isEmpty) {
                                    final input = await _askForEmail(context, null);
                                    if (input == null || input.trim().isEmpty) {
                                      showCustomSnackbar(context, 'Envio cancelado: e-mail não informado.');
                                      return;
                                    }
                                    destinatario = input;
                                  }

                                  // chama a função que envia o e-mail (definida em outro arquivo)
                                  await enviarEmpenhoComPDF(
                                    destinatario: destinatario,
                                    assunto: 'Nota Fiscal ${nota['NE']}',
                                    mensagem:
                                        'Segue a nota fiscal referente ao empenho ${nota['NE']}.\nFavorecido: ${nota['favorecido']}.',
                                    caminhoPDF: pdfUrl,
                                  );

                                  showCustomSnackbar(
                                      context, 'E-mail enviado com sucesso para $destinatario!');
                                } catch (e) {
                                  showCustomSnackbar(context, 'Erro ao enviar e-mail: $e');
                                }
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, nota['id'], nota['NE']),
                            ),

                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.orange),
                              onPressed: () async {
                                try {
                                  await downloadNota(nota['NE'].toString());
                                  showCustomSnackbar(context, 'Download iniciado para ${nota['NE']}');
                                } catch (e) {
                                  showCustomSnackbar(context, 'Erro ao baixar PDF: $e');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  UploadPdfPage.uploadMultiplePdfs(
                    context,
                    onReload: () {
                      setState(() {
                        _fetchNotas();
                      });
                    },
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Empenho'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
