import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/main_scaffold/header.dart';
import 'package:sistema_almox/widgets/main_scaffold/navbar.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/screens/admin.dart';
import 'package:sistema_almox/screens/consultas/index.dart';
import 'package:sistema_almox/screens/consultas_medico/index.dart';
import 'package:sistema_almox/screens/estoque.dart';
import 'package:sistema_almox/screens/home.dart';
import 'package:sistema_almox/screens/pedidos.dart';
import 'package:sistema_almox/screens/perfil.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/mudar_senha.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];
  List<NavBarItemInfo> _navBarItemsInfo = [];

  @override
  void initState() {
    super.initState();
    _buildNavigationLists();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkFirstLogin();
    });
  }

  @override
  void didUpdateWidget(MainScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildNavigationLists();

    // Se o índice selecionado for inválido, resetar para 0
    if (_selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }
  }

  void _checkFirstLogin() {
    final userService = Provider.of<UserService>(context, listen: false);

    if (userService.currentUser?.primeiroLogin == true) {
      showCustomBottomSheet(
        context: context,
        title: 'Redefina Sua Senha',
        child: const ChangePasswordForm(),
      );
    }
  }

  void _buildNavigationLists() {
    final pages = <Widget>[];
    final navBarItemsInfo = <NavBarItemInfo>[];

    pages.add(const HomeScreen());
    navBarItemsInfo.add(
      NavBarItemInfo(
        'assets/icons/navbar/home.svg',
        'Início',
        navBarItemsInfo.length,
      ),
    );

    if (UserService.instance.can(AppPermission.viewStockItems) ||
        UserService.instance.can(AppPermission.viewPharmacyItems)) {
      pages.add(const StockScreen());
      navBarItemsInfo.add(
        NavBarItemInfo(
          'assets/icons/navbar/estoque.svg',
          'Estoque',
          navBarItemsInfo.length,
        ),
      );
    }

    final currentUser = UserService.instance.currentUser;
    final isMedico = currentUser?.idSetor == 4;

    if (UserService.instance.can(AppPermission.accessAdminScreen)) {
      pages.add(const AdminScreen());
      navBarItemsInfo.add(
        NavBarItemInfo(
          'assets/icons/navbar/admin.svg',
          'Admin',
          navBarItemsInfo.length,
        ),
      );
    }

    // Pedidos não aparece para médicos
    if (!isMedico) {
      pages.add(const OrderScreen());
      navBarItemsInfo.add(
        NavBarItemInfo(
          'assets/icons/navbar/pedidos.svg',
          'Pedidos',
          navBarItemsInfo.length,
        ),
      );
    }

    // Consultas só aparece para pacientes (não médicos)
    if (!isMedico) {
      pages.add(const ConsultasScreen());
      navBarItemsInfo.add(
        NavBarItemInfo(
          'assets/icons/calendar.svg',
          'Consultas',
          navBarItemsInfo.length,
        ),
      );
    }

    // Minhas Consultas só aparece para médicos
    if (isMedico) {
      pages.add(const ConsultasMedicoScreen());
      navBarItemsInfo.add(
        NavBarItemInfo(
          'assets/icons/calendar.svg',
          'Minhas Consultas',
          navBarItemsInfo.length,
        ),
      );
    }

    pages.add(const ProfileScreen());
    navBarItemsInfo.add(
      NavBarItemInfo(
        'assets/icons/navbar/perfil.svg',
        'Perfil',
        navBarItemsInfo.length,
      ),
    );

    _pages = pages;
    _navBarItemsInfo = navBarItemsInfo;
  }

  int findPageIndexByName(String name) {
    final index = _navBarItemsInfo.indexWhere((item) => item.label == name);
    return index != -1 ? index : 0;
  }

  void onItemTapped(int index) {
    setState(() {
      if (index >= 0 && index < _pages.length) {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService.instance;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: AnimatedBuilder(
            animation: UserService.instance,
            builder: (context, child) {
              return CustomHeader(onProfileTap: onItemTapped);
            },
          ),
        ),

        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: IndexedStack(
                index: _pages.isEmpty || _selectedIndex >= _pages.length
                    ? 0
                    : _selectedIndex,
                children: _pages.isEmpty ? [const HomeScreen()] : _pages,
              ),
            ),

            Positioned(
              bottom: 20.0,
              right: 20.0,
              child: AnimatedBuilder(
                animation: userService,
                builder: (context, child) {
                  final isCoronel = userService.currentUser?.nivelAcesso == 3;

                  final int profilePageIndex = findPageIndexByName('Perfil');
                  final int adminPageIndex = findPageIndexByName('Admin');

                  if (!isCoronel ||
                      _selectedIndex == profilePageIndex ||
                      _selectedIndex == adminPageIndex) {
                    return const SizedBox.shrink();
                  }

                  final String tooltip = 'Trocar Visualização';

                  return FloatingActionButton(
                    onPressed: () {
                      userService.toggleViewingSector();
                    },
                    tooltip: tooltip,
                    backgroundColor: brandBlueLight,
                    foregroundColor: Colors.white,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/switch.svg',
                      colorFilter: const ColorFilter.mode(
                        brandBlue,
                        BlendMode.srcIn,
                      ),
                      width: 24,
                      height: 24,
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        bottomNavigationBar: CustomNavBar(
          selectedIndex: _selectedIndex,
          navBarItemsInfo: _navBarItemsInfo,
          onItemTapped: onItemTapped,
        ),
      ),
    );
  }
}
