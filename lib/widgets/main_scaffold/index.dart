import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_almox/widgets/main_scaffold/header.dart';
import 'package:sistema_almox/widgets/main_scaffold/navbar.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/screens/admin.dart';
import 'package:sistema_almox/screens/estoque.dart';
import 'package:sistema_almox/screens/home.dart';
import 'package:sistema_almox/screens/pedidos.dart';
import 'package:sistema_almox/screens/perfil.dart';
import 'package:sistema_almox/services/user_service.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  String fotoUrl = 'assets/foto-perfil.png';

  late final List<Widget> _pages;
  late final List<NavBarItemInfo> _navBarItemsInfo;

  @override
  void initState() {
    super.initState();
    _buildNavigationLists();
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

    pages.add(const StockScreen());
    navBarItemsInfo.add(
      NavBarItemInfo(
        'assets/icons/navbar/estoque.svg',
        'Estoque',
        navBarItemsInfo.length,
      ),
    );

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

    pages.add(const OrderScreen());
    navBarItemsInfo.add(
      NavBarItemInfo(
        'assets/icons/navbar/pedidos.svg',
        'Pedidos',
        navBarItemsInfo.length,
      ),
    );

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: CustomHeader(
          fotoUrl: fotoUrl,
          navBarItemsInfo: _navBarItemsInfo,
          onProfileTap: _onItemTapped,
        ),

        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _pages.elementAt(_selectedIndex),
        ),

        bottomNavigationBar: CustomNavBar(
          selectedIndex: _selectedIndex,
          navBarItemsInfo: _navBarItemsInfo,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
