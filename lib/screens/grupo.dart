import 'package:flutter/material.dart';
import 'package:sistema_almox/services/group_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/snackbar.dart'; 
import 'EditGroupScreen.dart';
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

  Future<void> _showDeleteDialog(BuildContext context, int groupId, String groupName) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Excluir Grupo'),
        content: Text('Tem certeza que deseja excluir o grupo "$groupName"?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop(); 

              try {
                if (groupId == 1 || groupId == 2 || groupId == 3) {
                  showCustomSnackbar(
                    context,
                    'Este grupo não pode ser deletado.',
                    isError: true,
                  );
                  return;
                }

                await _groupService.deleteGroup(groupId);
                await _fetchGroups();

                if (mounted) {
                  showCustomSnackbar(
                    context,
                    'Grupo excluído e itens realocados com sucesso!',
                    isError: false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  showCustomSnackbar(
                    context,
                    'Erro ao excluir grupo: $e',
                    isError: true,
                  );
                }
              }
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final filteredGroups = _groups.where((g) {
      final name = g['grp_nome']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center( 
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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

                const SizedBox(height: 16),

                Text(
                  'ID do setor atual: ${_userService.viewingSectorId ?? 'Não definido'}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
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

                Center(
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Nome')),
                      DataColumn(label: Text('Ações')),
                    ],
                    rows: filteredGroups.map((group) {
                      return DataRow(cells: [
                        DataCell(Text(group['id'].toString())),
                        DataCell(Text(group['grp_nome'] ?? '')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                tooltip: 'Editar grupo',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditGroupScreen(
                                        groupId: group['id'],
                                        initialName: group['grp_nome'] ?? '',
                                        initialSectorId: group['grp_setor_id'] ?? _userService.viewingSectorId ?? 0,
                                      ),
                                    ),
                                  ).then((value) => _fetchGroups());
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Excluir grupo',
                                onPressed: () {
                                  _showDeleteDialog(context, group['id'], group['grp_nome'] ?? '');
                                },
                              ),
                            ],
                          ),
                        ),

                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
