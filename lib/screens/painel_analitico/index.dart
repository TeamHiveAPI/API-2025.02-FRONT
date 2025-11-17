import 'package:flutter/material.dart';
import 'package:sistema_almox/screens/painel_analitico/consumo_panel.dart';
import 'package:sistema_almox/services/previsao.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/change_ip.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistema_almox/screens/painel_analitico/previsao_panel.dart';

enum AnaliticoPanel { previsao, consumo }

class PainelAnaliticoScreen extends StatefulWidget {
  const PainelAnaliticoScreen({super.key});

  @override
  State<PainelAnaliticoScreen> createState() => _PainelAnaliticoScreenState();
}

class _PainelAnaliticoScreenState extends State<PainelAnaliticoScreen> {
  AnaliticoPanel _selectedPanel = AnaliticoPanel.previsao;
  final PrevisaoService _previsaoService = PrevisaoService();
  static const String _ipCacheKey = 'last_api_ip';
  String _apiIp = "";

  @override
  void initState() {
    super.initState();
    _loadCachedIp();
  }

  Future<void> _loadCachedIp() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedIp = prefs.getString(_ipCacheKey) ?? "";
    setState(() {
      _apiIp = cachedIp;
    });
    _previsaoService.setApiIp(cachedIp);
  }

  Future<void> _saveIpToCache(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipCacheKey, ip);
  }

  void _showConfigIpModal() {
    showCustomBottomSheet(
      context: context,
      title: 'Configurar Endereço IP',
      child: ConfigIpModal(
        currentIp: _apiIp,
        onSave: (newIp) {
          setState(() {
            _apiIp = newIp;
          });

          _previsaoService.setApiIp(newIp);
          _saveIpToCache(newIp);

          showCustomSnackbar(context, 'IP configurado com sucesso!');
        },
      ),
    );
  }

  Widget _buildPanelSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        children: [
          CustomButton(
            text: 'Previsão de Demanda',
            customIcon: "assets/icons/box.svg",
            secondary: _selectedPanel != AnaliticoPanel.previsao,
            onPressed: _selectedPanel == AnaliticoPanel.previsao
                ? () {}
                : () =>
                      setState(() => _selectedPanel = AnaliticoPanel.previsao),
          ),
          const SizedBox(width: 8),
          CustomButton(
            text: 'Consumo por Setor',

            secondary: _selectedPanel != AnaliticoPanel.consumo,

            onPressed: _selectedPanel == AnaliticoPanel.consumo
                ? () {}
                : () => setState(() => _selectedPanel = AnaliticoPanel.consumo),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPanel() {
    switch (_selectedPanel) {
      case AnaliticoPanel.previsao:
        return PrevisaoPanel(previsaoService: _previsaoService);

      case AnaliticoPanel.consumo:
        return ConsumoPanel(previsaoService: _previsaoService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            InternalPageHeader(
              title: 'Painel Analítico',
              customActionIcon: "assets/icons/settings.svg",
              onActionPressed: _showConfigIpModal,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _buildPanelSelector(),
                  const SizedBox(height: 20),
                  _buildCurrentPanel(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
