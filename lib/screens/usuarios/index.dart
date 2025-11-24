import 'package:flutter/material.dart';
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/main.dart';
import 'package:sistema_almox/screens/usuarios/build_lieutenant_cards.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/data_table/content/users_list.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/modal/content/mostrar_senha_temp.dart';
import 'package:sistema_almox/widgets/radio_button.dart';
import 'package:sistema_almox/widgets/toggle_sector_buttons.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with RouteAware {
  final _userService = UserService.instance;
  String _searchQuery = '';
  bool _showInactiveUsers = false;
  int _tableKeyCounter = 0;

  @override
  void initState() {
    super.initState();
    _userService.addListener(_onSectorChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(
      this as RouteAware,
      ModalRoute.of(context) as PageRoute,
    );
  }

  @override
  void didPopNext() {
    super.didPopNext();
    setState(() {
      _tableKeyCounter++;
    });
  }

  @override
  void dispose() {
    _userService.removeListener(_onSectorChange);
    routeObserver.unsubscribe(this as RouteAware);
    super.dispose();
  }

  void _onSectorChange() {
    setState(() {});
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _userService.currentUser;

    final bool isCoronel = currentUser!.role == UserRole.coronel;

    final int? sectorForTable = isCoronel
        ? _userService.viewingSectorId
        : currentUser.idSetor;

    final String sectorName = sectorForTable == 1
        ? 'Almoxarifado'
        : (sectorForTable == 2 ? 'Farmácia' : '');

    final String listTitle = !isCoronel && sectorName.isNotEmpty
        ? 'Setor $sectorName'
        : 'Listagem de Soldados';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InternalPageHeader(title: 'Listagem de Usuários'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    if (isCoronel)
                      CustomButton(
                        text: 'Cadastrar Novo Soldado',
                        icon: Icons.add,
                        widthPercent: 1.0,
                        onPressed: () async {
                          final result = await Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.newSoldier);

                          if (result != null &&
                              result is Map<String, dynamic> &&
                              context.mounted) {
                            final String password =
                                result['password'] as String;
                            showTemporaryPasswordModal(context, password);
                          }
                        },
                      ),

                    if (isCoronel) const SizedBox(height: 20),
                    if (isCoronel) ...[
                      const LieutenantCards(),
                      const SizedBox(height: 32),
                    ] else
                      ...[],

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        listTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isCoronel) const SizedBox(height: 16),

                    if (isCoronel && _userService.viewingSectorId != null)
                      SectorToggleButtons(
                        currentSectorId: _userService.viewingSectorId!,
                        onSectorSelected: (selectedSector) {
                          _userService.setViewingSector(selectedSector);
                        },
                      ),

                    const SizedBox(height: 16),

                    GenericSearchInput(
                      onSearchChanged: _handleSearch,
                      hintText: 'Pesquisar',
                    ),

                    const SizedBox(height: 16),

                    CustomRadioButton<bool>(
                      label: 'Mostrar usuários inativos',
                      value: true,
                      smaller: true,
                      groupValue: _showInactiveUsers,
                      onChanged: (value) {
                        setState(() {
                          _showInactiveUsers = !_showInactiveUsers;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    if (sectorForTable != null)
                      UsersList(
                        viewingSectorId: sectorForTable,
                        searchQuery: _searchQuery,
                        showInactive: _showInactiveUsers,
                        key: ValueKey(_tableKeyCounter),
                      )
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'Setor de visualização não definido.',
                            style: TextStyle(color: text40),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
