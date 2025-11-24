import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/data_table/content/group_list.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/novo_grupo.dart';
import 'package:sistema_almox/widgets/toggle_sector_buttons.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  String _searchQuery = '';
  int _listKey = 0;
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService.instance;

  @override
  void initState() {
    super.initState();
    _userService.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    _userService.removeListener(_onUserChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onUserChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _openNewGroupModal(BuildContext context) async {
    final result = await showCustomBottomSheet(
      context: context,
      title: "Registrar Novo Grupo",
      child: const NovoGrupoModal(),
    );

    if (result == true) {
      if (mounted) {
        setState(() {
          _listKey++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _userService.currentUser;
    final bool isCoronel = currentUser?.role == UserRole.coronel;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const InternalPageHeader(title: "Listagem de Grupos"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Cadastrar Novo Grupo',
                    icon: Icons.add,
                    widthPercent: 1.0,
                    onPressed: () {
                      _openNewGroupModal(context);
                    },
                  ),

                  const SizedBox(height: 20),

                  if (isCoronel) ...[
                    SectorToggleButtons(
                      currentSectorId: _userService.viewingSectorId ?? 1,
                      onSectorSelected: (newSectorId) {
                        _userService.setViewingSector(newSectorId);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GenericSearchInput(
                          controller: _searchController,
                          onSearchChanged: _handleSearch,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  GroupList(
                    key: ValueKey("$_listKey-${_userService.viewingSectorId}"),
                    searchQuery: _searchQuery,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
