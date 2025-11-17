import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/previsao.dart';
import 'package:sistema_almox/widgets/charts/consumo_setor.dart';

class ConsumoPanel extends StatefulWidget {
  final PrevisaoService previsaoService;

  const ConsumoPanel({super.key, required this.previsaoService});

  @override
  State<ConsumoPanel> createState() => _ConsumoPanelState();
}

class _ConsumoPanelState extends State<ConsumoPanel> {
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, int>? _chartDataTotals;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: brightGray,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(
              color: deleteRed,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
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

    return const Center(
      child: Text('Nenhum dado para exibir.', style: TextStyle(color: text60)),
    );
  }
}
