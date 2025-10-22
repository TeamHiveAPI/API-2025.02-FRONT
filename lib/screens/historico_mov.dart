import 'package:flutter/material.dart';
import 'package:sistema_almox/utils/generate_audit_mixin.dart';
import 'package:sistema_almox/widgets/data_table/content/recent_movimentation.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';

class AllMovementsScreen extends StatefulWidget {
  const AllMovementsScreen({super.key});

  @override
  State<AllMovementsScreen> createState() => _AllMovementsScreenState();
}

class _AllMovementsScreenState extends State<AllMovementsScreen>
    with GenerateAuditMixin<AllMovementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isDownloading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _setDownloadingState(bool isDownloading) {
    setState(() {
      _isDownloading = isDownloading;
    });
  }

  Future<void> _baixarAuditoria() async {
    await handleBaixarAuditoria(
      searchQuery: _searchQuery,
      setLoading: _setDownloadingState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InternalPageHeader(title: 'Histórico de Movimentações'),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      GenericSearchInput(
                        controller: _searchController,
                        onSearchChanged: _handleSearch,
                        hintText: 'Pesquisar',
                      ),
                      const SizedBox(height: 20),
                      MovimentationLogTable(
                        isRecentView: false,
                        searchQuery: _searchQuery,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            InternalPageBottom(
              buttonText: 'Baixar Relatório de Auditoria',
              onButtonPressed: _baixarAuditoria,
              isLoading: _isDownloading,
            ),
          ],
        ),
      ),
    );
  }
}
