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
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
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

    // Início - sempre disponível
    pages.add(const HomeScreen());
    navBarItemsInfo.add(
      NavBarItemInfo(
        'assets/icons/navbar/home.svg',
        'Início',
        navBarItemsInfo.length,
      ),
    );

    // Estoque - apenas para quem pode ver itens de estoque
    if (UserService.instance.can(AppPermission.viewStockItems)) {
      pages.add(const StockScreen());
      navBarItemsInfo.add(
        NavBarItemInfo(
          'assets/icons/navbar/estoque.svg',
          'Estoque',
          navBarItemsInfo.length,
        ),
      );
    }

    // Farmácia - apenas para quem pode ver itens de farmácia
    if (UserService.instance.can(AppPermission.viewPharmacyItems)) {
      pages.add(const StockScreen()); // Usar mesma tela, mas filtrar por setor
      navBarItemsInfo.add(
        NavBarItemInfo(
          'assets/icons/navbar/estoque.svg', // Usar ícone de farmácia se tiver
          'Farmácia',
          navBarItemsInfo.length,
        ),
      );
    }

    // Admin - apenas para tenentes e coronel
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

    // Pedidos - sempre disponível (todos podem criar pedidos)
    pages.add(const OrderScreen());
    navBarItemsInfo.add(
      NavBarItemInfo(
        'assets/icons/navbar/pedidos.svg',
        'Pedidos',
        navBarItemsInfo.length,
      ),
    );

    // Perfil - sempre disponível
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
          onProfileTap: onItemTapped,
        ),

        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _pages.elementAt(_selectedIndex),
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
