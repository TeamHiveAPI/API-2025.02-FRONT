import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/previsao.dart';
import 'package:sistema_almox/widgets/error.dart';

import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:sistema_almox/widgets/toggle_sector_buttons.dart';

class RiscoRupturaPanel extends StatefulWidget {
  final PrevisaoService previsaoService;

  const RiscoRupturaPanel({super.key, required this.previsaoService});

  @override
  State<RiscoRupturaPanel> createState() => _RiscoRupturaPanelState();
}

class _RiscoRupturaPanelState extends State<RiscoRupturaPanel> {
  int _selectedSectorId = 1;
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _riscoData = [];
  bool _isRequestInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Color _getColorFromHex(String hexColor) {
    switch (hexColor) {
      case "red":
        return deleteRed;
      case "orange":
        return Colors.orange;
      case "yellow":
        return Colors.yellow.shade700;
      case "green":
        return successGreen;
      default:
        return text40;
    }
  }

  Future<void> _loadData() async {
    if (_isRequestInProgress) return;

    setState(() {
      _isLoading = true;
      _isRequestInProgress = true;
      _errorMessage = null;
    });

    final closeLoadingSnackbar = showCustomSnackbar(
      context,
      "Gerando gráfico...",
      isLoading: true,
      onCancel: () {
        widget.previsaoService.cancelCurrentRequest();
      },
    );

    try {
      final data = await widget.previsaoService.buscarRiscoRuptura(
        _selectedSectorId,
      );
      setState(() {
        _riscoData = data['itens'] as List<dynamic>;
        _errorMessage = null;
      });
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains("cancelada pelo usuário")) {
        errorMsg = "Análise cancelada.";
      }
      setState(() {
        _errorMessage = errorMsg;
      });

      if (!errorMsg.contains("cancelada")) {
        showCustomSnackbar(context, "Erro ao analisar itens.", isError: true);
      }
    } finally {
      closeLoadingSnackbar();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRequestInProgress = false;
        });
      }
    }
  }

  Widget _buildSectorSelector() {
    return SectorToggleButtons(
      currentSectorId: _selectedSectorId,
      onSectorSelected: (newId) {
        if (_selectedSectorId == newId) return;
        setState(() {
          _selectedSectorId = newId;
        });
        _loadData();
      },
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: brightGray,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: ErrorMessage(message: _errorMessage!),
      );
    }

    if (_riscoData.isEmpty) {
      if (_isLoading) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: brightGray,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: ErrorMessage(
          message:
              "Não há dados de movimentação o suficiente para gerar previsões neste setor.",
        ),
      );
    }

    return ListView.builder(
      itemCount: _riscoData.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = _riscoData[index] as Map<String, dynamic>;
        return _buildRiskCard(item);
      },
    );
  }

  Widget _buildRiskCard(Map<String, dynamic> item) {
    final String nome = item['nome'] ?? 'Item Desconhecido';
    final String nivelRisco = item['nivel_risco'] ?? 'N/A';
    final int probabilidade = item['probabilidade_ruptura'] ?? 0;
    final Color corRisco = _getColorFromHex(item['cor'] ?? 'grey');

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(color: corRisco, width: 4.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      color: text80,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Nível de Risco: $nivelRisco",
                    style: TextStyle(
                      color: corRisco,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$probabilidade%",
                  style: TextStyle(
                    color: corRisco,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  "Risco (7d)",
                  style: const TextStyle(color: text40, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectorSelector(),
        const SizedBox(height: 24),
        _buildContent(),
      ],
    );
  }
}
