import 'package:flutter/material.dart';
import 'package:sistema_almox/services/group_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _groups = [];
  final _groupService = GroupService();
  final _userService = UserService.instance;

  int? get _currentSectorId => _userService.viewingSectorId;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    if (_currentSectorId == null) return;

    final groups = await _groupService.fetchGroupsBySector(_currentSectorId!);
    if (mounted) {
      setState(() {
        _groups = groups;
      });
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = _groups.where((g) {
      final name = g['grp_nome']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomButton(
              text: 'Cadastrar Novo Grupo',
              icon: Icons.add,
              widthPercent: 1.0,
              onPressed: () {
                Navigator.pushNamed(context, '/novo-grupo').then((value) {
                  _fetchGroups();
                });
              },
            ),

            Text(
  'ID do setor atual: ${_userService.viewingSectorId ?? 'Não definido'}',
  style: TextStyle(fontSize: 16, color: Colors.red),
)
,

            const SizedBox(height: 24),

            const Text(
              'Listagem de Grupos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            GenericSearchInput(
              controller: _searchController,
              onSearchChanged: _handleSearch,
            ),

            const SizedBox(height: 20),

            DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Nome')),
                
              ],
              
              rows: filteredGroups.map((group) {
                return DataRow(cells: [
                  DataCell(Text(group['id'].toString())),
                  DataCell(Text(group['grp_nome'] ?? '')),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
