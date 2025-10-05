import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/group_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DecodedItem {
  final String nome;
  final String numFicha;
  final String nomeGrupo;
  final int totalLotes;
  final Map<String, dynamic> payload;

  DecodedItem({
    required this.nome,
    required this.numFicha,
    required this.nomeGrupo,
    required this.totalLotes,
    required this.payload,
  });
}

class MultiRegisterModal extends StatefulWidget {
  final VoidCallback? onSuccess;

  const MultiRegisterModal({super.key, this.onSuccess});

  @override
  State<MultiRegisterModal> createState() => _MultiRegisterModalState();
}

class _MultiRegisterModalState extends State<MultiRegisterModal> {
  bool _isProcessingFile = false;
  bool _isSaving = false;
  String? _statusMessage;
  bool _isError = false;

  List<DecodedItem> _decodedItems = [];

  double _progressValue = 0.0;
  String _progressText = '';

  void _updateProgress(double value, String text) {
    setState(() {
      _progressValue = value;
      _progressText = text;
    });
  }

  final _groupService = GroupService();
  final _userService = UserService.instance;

  Future<void> _pickAndProcessFile() async {
    setState(() {
      _isProcessingFile = true;
      _statusMessage = null;
      _isError = false;
      _decodedItems = [];
    });

    try {
      _updateProgress(0.1, 'Selecionando arquivo...');
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null) {
        setState(() => _isProcessingFile = false);
        return;
      }

      _updateProgress(0.2, 'Buscando informações de grupos...');
      final viewingSectorId = _userService.viewingSectorId;
      if (viewingSectorId == null)
        throw Exception("Setor do usuário não identificado.");

      final groupsData = await _groupService.fetchGroupsBySector(
        viewingSectorId,
      );
      final groupMap = {
        for (var g in groupsData) g[GrupoFields.id]: g[GrupoFields.nome],
      };

      final fileExtension = result.files.single.extension?.toLowerCase();
      if (fileExtension != 'csv') {
        throw Exception(
          'Arquivo inválido. Por favor, selecione um arquivo CSV.',
        );
      }

      _updateProgress(0.4, 'Analisando formato do arquivo...');
      final path = result.files.single.path!;
      final bytes = await File(path).readAsBytes();
      final content = utf8.decode(bytes);

      final List<List<dynamic>> csvAsListOfLists = const CsvToListConverter(
        fieldDelimiter: ';',
        eol: '\n',
      ).convert(content);

      if (csvAsListOfLists.length < 2) {
        throw Exception(
          'O arquivo CSV está vazio ou contém apenas o cabeçalho.',
        );
      }

      final header = csvAsListOfLists.first
          .map((h) => h.toString().trim().toLowerCase())
          .toList();
      const requiredColumns = [
        'nome',
        'num_ficha',
        'unidade',
        'min_estoque',
        'perecivel',
        'grupo_id',
        'controlado',
        'quantidade_lote',
        'data_validade_lote',
      ];

      final missingColumns = requiredColumns
          .where((col) => !header.contains(col))
          .toList();

      if (missingColumns.isNotEmpty) {
        throw Exception(
          'O arquivo CSV está com o formato incorreto. Colunas obrigatórias ausentes: ${missingColumns.join(', ')}',
        );
      }

      _updateProgress(0.7, 'Processando e agrupando dados...');
      final rawHeader = csvAsListOfLists.first
          .map((h) => h.toString().trim().toLowerCase())
          .toList();
      final dataRows = csvAsListOfLists.sublist(1);
      final List<Map<String, dynamic>> csvData = dataRows.map((row) {
        final cleanedRow = row.map((cell) => cell.toString().trim()).toList();
        return Map.fromIterables(rawHeader, cleanedRow);
      }).toList();

      final Map<String, dynamic> itemsAgrupados = {};

      for (final row in csvData) {
        final numFicha = row['num_ficha'];
        if (numFicha == null || numFicha.toString().isEmpty) continue;

        if (!itemsAgrupados.containsKey(numFicha)) {
          itemsAgrupados[numFicha] = {
            'nome': row['nome'],
            'num_ficha': numFicha,
            'unidade': row['unidade'],
            'min_estoque': int.tryParse(row['min_estoque'].toString()) ?? 0,
            'perecivel': [
              'sim',
              'true',
              '1',
            ].contains(row['perecivel'].toString().toLowerCase()),
            'grupo_id': int.tryParse(row['grupo_id'].toString()) ?? 1,
            'controlado': [
              'sim',
              'true',
              '1',
            ].contains(row['controlado'].toString().toLowerCase()),
            'ativo': true,
            'qtd_reservada': 0,
            'lotes': [],
          };
        }

        itemsAgrupados[numFicha]['lotes'].add({
          'qtd_atual': int.tryParse(row['quantidade_lote'].toString()) ?? 0,
          'data_validade_lote': row['data_validade_lote'],
          'data_entrada': DateTime.now().toIso8601String().substring(0, 10),
        });
      }

      final csvGroupIds = itemsAgrupados.values
          .map<int>((item) => item['grupo_id'])
          .toSet();

      final validGroupIds = groupMap.keys.toSet();
      final invalidGroupIds = csvGroupIds.difference(validGroupIds);
      if (invalidGroupIds.isNotEmpty) {
        throw Exception(
          'O arquivo contém IDs de grupo que não existem ou não pertencem ao setor atual: ${invalidGroupIds.join(', ')}',
        );
      }

      final List<DecodedItem> itemsToShow = itemsAgrupados.entries.map((entry) {
        final itemData = entry.value;
        final int grupoId = itemData['grupo_id'];
        final String nomeGrupo = groupMap[grupoId] ?? 'Erro';
        return DecodedItem(
          nome: itemData['nome'],
          numFicha: itemData['num_ficha'],
          nomeGrupo: nomeGrupo,
          totalLotes: (itemData['lotes'] as List).length,
          payload: itemData,
        );
      }).toList();

      _updateProgress(
        1.0,
        '${itemsToShow.length} itens prontos para cadastrar.',
      );
      setState(() {
        _decodedItems = itemsToShow;
        _isProcessingFile = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = e.toString().replaceAll('Exception: ', '');
        _isError = true;
        _isProcessingFile = false;
      });
    }
  }

  Future<void> _performMultiRegister() async {
    if (_decodedItems.isEmpty) return;

    setState(() {
      _isSaving = true;
      _isError = false;
      _statusMessage = null;
    });

    try {
      final List<dynamic> payloadFinal = _decodedItems
          .map((item) => item.payload)
          .toList();

      await Supabase.instance.client.rpc(
        'criar_multiplos_itens_com_lotes',
        params: {'payload': payloadFinal},
      );

      if (mounted) {
        showCustomSnackbar(context, 'Cadastro em lote realizado com sucesso!');
        widget.onSuccess?.call();
      }
    } on PostgrestException catch (e) {
      String errorMessage;
      if (e.message.contains('item_it_num_ficha_key')) {
        errorMessage =
            'Um ou mais itens no arquivo CSV possuem um Nº de Ficha que já está em uso.';
      } else {
        errorMessage = 'Erro no banco de dados: ${e.message}';
      }

      if (mounted) {
        showCustomSnackbar(context, errorMessage, isError: true);
      }
    } catch (e) {
      final errorMessage = 'Ocorreu um erro inesperado: ${e.toString()}';
      if (mounted) {
        setState(() {
          _statusMessage = errorMessage;
          _isError = true;
        });
        showCustomSnackbar(context, errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showInfoText =
        !_isProcessingFile && _decodedItems.isEmpty && !_isError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showInfoText) ...[
          const Text(
            'Importe um arquivo CSV com os itens e seus lotes. Cada linha deve representar um lote.',
            textAlign: TextAlign.center,
            style: TextStyle(color: text60, fontSize: 14),
          ),
          const SizedBox(height: 16),
        ],

        CustomButton(
          text: 'Selecionar Arquivo CSV',
          onPressed: _isProcessingFile || _isSaving
              ? null
              : _pickAndProcessFile,
          icon: Icons.upload_file,
        ),

        if (_isProcessingFile)
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(brandBlue),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(_progressText, style: const TextStyle(color: text60)),
              ],
            ),
          ),

        if (_decodedItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _decodedItems.length,
              itemBuilder: (context, index) {
                final item = _decodedItems[index];
                final String loteText = item.totalLotes == 1 ? 'lote' : 'lotes';
                return ListTile(
                  title: Text(
                    item.nome,
                    style: TextStyle(fontSize: 15, color: text40),
                  ),
                  subtitle: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: brandBlueLight,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          item.numFicha,
                          style: const TextStyle(
                            color: brandBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.nomeGrupo,
                          style: TextStyle(color: text80),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${item.totalLotes} $loteText',
                    style: TextStyle(color: text60),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: successGreenLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/success.svg',
                  colorFilter: const ColorFilter.mode(
                    successGreen,
                    BlendMode.srcIn,
                  ),
                  width: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_decodedItems.length} itens prontos para cadastro.',
                  style: const TextStyle(
                    color: successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        if (_statusMessage != null && _isError)
          Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/warning.svg',
                      colorFilter: const ColorFilter.mode(
                        deleteRed,
                        BlendMode.srcIn,
                      ),
                      width: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Erro',
                      style: TextStyle(
                        color: deleteRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: text40),
                ),
              ],
            ),
          ),

        if (_statusMessage != null &&
            !_isError &&
            _decodedItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            _statusMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: text60, fontWeight: FontWeight.bold),
          ),
        ],

        if (_decodedItems.isNotEmpty)
          CustomButton(
            text: 'Realizar Multi Cadastro',
            onPressed: _isSaving || _isProcessingFile
                ? null
                : _performMultiRegister,
            isLoading: _isSaving,
            icon: Icons.check,
          ),
      ],
    );
  }
}
