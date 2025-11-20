import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/previsao.dart';
import 'package:sistema_almox/widgets/charts/consumo_setor.dart';
import 'package:sistema_almox/widgets/error.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class ConsumoPanel extends StatefulWidget {
  final PrevisaoService previsaoService;

  const ConsumoPanel({super.key, required this.previsaoService});

  @override
  State<ConsumoPanel> createState() => _ConsumoPanelState();
}

class _ConsumoPanelState extends State<ConsumoPanel> {
  bool _isLoading = true;
  bool _isRequestInProgress = false;
  String? _errorMessage;

  Map<String, int>? _chartDataTotals;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
      final data = await widget.previsaoService.buscarConsumoPorSetor();

      final Map<String, int> parsedTotals = {
        "almoxReal": data['almoxarifado']['real_total'] as int,
        "almoxPrevisto": data['almoxarifado']['previsto_total'] as int,
        "farmReal": data['farmacia']['real_total'] as int,
        "farmPrevisto": data['farmacia']['previsto_total'] as int,
      };

      setState(() {
        _chartDataTotals = parsedTotals;
      });
    } catch (e) {
      String errorMsg = e.toString();
      // Tratamento para cancelamento
      if (errorMsg.contains("cancelada pelo usuário")) {
        errorMsg = "Análise cancelada.";
      } else {
        // Se for erro real, mostra no snackbar também
        showCustomSnackbar(context, "Erro ao buscar dados.", isError: true);
      }
      
      setState(() {
        _errorMessage = errorMsg;
      });
    } finally {
      // 2. FECHA O SNACKBAR
      closeLoadingSnackbar();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRequestInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // Usamos um SizedBox para definir a altura, mas o estilo vem do _buildContent
    return SizedBox(
      height: screenHeight * 0.5,
      child: _buildContent(),
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
        child: ErrorMessage(
          message:
              "Não há dados de movimentação o suficiente para gerar previsões neste setor.",
        ),
      );
    }

    if (_chartDataTotals != null) {
      return ConsumoSetorChart(
          almoxarifadoRealTotal: _chartDataTotals!['almoxReal']!,
          almoxarifadoPrevistoTotal: _chartDataTotals!['almoxPrevisto']!,
          farmaciaRealTotal: _chartDataTotals!['farmReal']!,
          farmaciaPrevistoTotal: _chartDataTotals!['farmPrevisto']!,
        );
    }

    if (_isLoading) {
       return SizedBox.shrink();
    }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: brightGray,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: ErrorMessage(
          message:
              "Não há nenhum dado para exibir.",
        ),
      );
  }
}