import 'package:flutter/material.dart';
import 'package:sistema_almox/services/subirEmpenho.dart';
import 'package:sistema_almox/services/criar_empenho.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'notaEmpenhoFormsScreen.dart';
import 'package:sistema_almox/services/donwload_NE/download_nota.dart';
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

  @override
  Widget build(BuildContext context) {
    final filteredNotas = _notas.where((n) {
    final query = _searchQuery.toLowerCase();
    final ne = n['NE']?.toString().toLowerCase() ?? '';
    final item = n['item']?.toString().toLowerCase() ?? '';
    final favorecido = n['favorecido']?.toString().toLowerCase() ?? '';
    final saldo = n['saldo']?.toString().toLowerCase() ?? '';

    return ne.contains(query) ||
          item.contains(query) ||
          favorecido.contains(query) ||
          saldo.contains(query);
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
                      DataCell(Text(nota['saldo']?.toString() ?? '')),
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
                              ).then((reload) {
                                if (reload == true) _fetchNotas();
                              });
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
                      )),
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
