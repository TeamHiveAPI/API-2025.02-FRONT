import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/item_service.dart';
import 'package:sistema_almox/services/previsao.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/charts/previsao_inventario.dart';
import 'package:sistema_almox/widgets/inputs/select.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class PrevisaoPanel extends StatefulWidget {
  final PrevisaoService previsaoService;

  const PrevisaoPanel({
    super.key,
    required this.previsaoService,
  });

  @override
  State<PrevisaoPanel> createState() => _PrevisaoPanelState();
}

class _PrevisaoPanelState extends State<PrevisaoPanel> {  
  bool _isLoadingChart = false;
  String? _errorMessage;
  int? _selectedItemId;

  bool _isLoadingItems = true;
  List<DropdownOption<int>> _itemOptions = [];

  int _estoqueAtual = 0;
  List<FlSpot>? _dadosGraficoInventario;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    
    final itemsList = await ItemService.instance.fetchItemsForDropdown();

    setState(() {
      _itemOptions = itemsList.map((item) {
        return DropdownOption(
          value: item['id'] as int,
          label: item['it_nome'] as String,
        );
      }).toList();

      if (_itemOptions.isNotEmpty) {
        _selectedItemId = _itemOptions.first.value;
      }
      _isLoadingItems = false;
    });
  }

  Future<void> buscarPrevisaoHibrida(int itemId) async {
    setState(() {
      _isLoadingChart = true;
      _errorMessage = null;
    });

    final closeLoadingSnackbar = showCustomSnackbar(
      context,
      "Calculando Previsão...",
      isLoading: true,
      onCancel: () {
        widget.previsaoService.cancelCurrentRequest();
      },
    );

    try {
      final (estoque, spots) =
          await widget.previsaoService.buscarPrevisaoHibrida(itemId);

      setState(() {
        _estoqueAtual = estoque;
        _dadosGraficoInventario = spots;
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      closeLoadingSnackbar();
      setState(() {
        _isLoadingChart = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    showCustomSnackbar(
      context,
      message,
      isError: true,
    );
  }

  Widget _buildChartArea() {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    final Widget currentContent;
    bool showBackgroundIcon = true;

    if (_errorMessage != null) {
      currentContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/warning.svg',
                colorFilter: const ColorFilter.mode(deleteRed, BlendMode.srcIn),
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
            _errorMessage!,
            style: TextStyle(fontSize: 16, color: text40),
            textAlign: TextAlign.center,
          ),
        ],
      );
      showBackgroundIcon = true;

    } else if (_dadosGraficoInventario != null && _dadosGraficoInventario!.isNotEmpty) {
      currentContent = PrevisaoInventarioChart(spots: _dadosGraficoInventario!);
      showBackgroundIcon = false;

    } else {
      currentContent = const Text(
        'Selecione um item e clique em "Gerar Previsão"',
        style: TextStyle(fontSize: 16, color: Colors.grey),
        textAlign: TextAlign.center,
      );
      showBackgroundIcon = true;
    }

    return Container(
      decoration: BoxDecoration(
        color: brightGray,
        borderRadius: BorderRadius.circular(4.0),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          if (showBackgroundIcon)
            Positioned(
              bottom: -50,
              right: -75,
              child: SvgPicture.asset(
                'assets/icons/chart.svg',
                width: screenHeight * 0.5,
                height: screenHeight * 0.5,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFF5F5F5),
                  BlendMode.srcIn,
                ),
              ),
            ),
            
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: currentContent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isLoadingItems)
          const Center(child: CircularProgressIndicator())
        else
          CustomDropdownInput<int>(
            upperLabel: 'SELECIONE UM ITEM',
            hintText: 'Selecione um item',
            value: _selectedItemId,
            items: _itemOptions,
            onChanged: (newValue) {
              setState(() {
                _selectedItemId = newValue;
                _dadosGraficoInventario = null;
                _estoqueAtual = 0;
                _errorMessage = null;
              });
            },
          ),
        SizedBox(height: 16),
        CustomButton(
          text: 'Gerar Previsão',
          customIcon: "assets/icons/flare.svg",
          widthPercent: 1.0,
          onPressed: _isLoadingChart || _selectedItemId == null
              ? null
              : () {
                  buscarPrevisaoHibrida(_selectedItemId!);
                },
        ),
        SizedBox(height: 16),
        
        if (_estoqueAtual > 0 &&
            !_isLoadingChart &&
            _dadosGraficoInventario != null)
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: coolGray,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/box.svg',
                    colorFilter: const ColorFilter.mode(text40, BlendMode.srcIn),
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Estoque Atual: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: text40,
                        ),
                      ),
                      Text(
                        '$_estoqueAtual unidades',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: text60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 16),
        
        SizedBox(
          height: screenHeight * 0.5,
          child: _buildChartArea(),
        ),
      ],
    );
  }
}