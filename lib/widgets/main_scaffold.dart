import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';

import '../config/permissions.dart';
import '../services/user_service.dart';

import '../screens/home.dart';
import '../screens/estoque.dart';
import '../screens/admin.dart';
import '../screens/pedidos.dart';
import '../screens/perfil.dart';

class _NavBarItemInfo {
  final String imagePath;
  final String label;
  final int index;

  _NavBarItemInfo(this.imagePath, this.label, this.index);
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;
  late final List<_NavBarItemInfo> _navBarItemsInfo;

  @override
  void initState() {
    super.initState();
    _buildNavigationLists();
  }

  void _buildNavigationLists() {
    final pages = <Widget>[];
    final navBarItemsInfo = <_NavBarItemInfo>[];

    pages.add(const HomeScreen());
    navBarItemsInfo.add(
      _NavBarItemInfo(
        'assets/icons/navbar/home.svg',
        'Início',
        navBarItemsInfo.length,
      ),
    );

    pages.add(const StockScreen());
    navBarItemsInfo.add(
      _NavBarItemInfo(
        'assets/icons/navbar/estoque.svg',
        'Estoque',
        navBarItemsInfo.length,
      ),
    );

    if (UserService.instance.can(AppPermission.accessAdminScreen)) {
      pages.add(const AdminScreen());
      navBarItemsInfo.add(
        _NavBarItemInfo(
          'assets/icons/navbar/admin.svg',
          'Admin',
          navBarItemsInfo.length,
        ),
      );
    }

    pages.add(const OrderScreen());
    navBarItemsInfo.add(
      _NavBarItemInfo(
        'assets/icons/navbar/pedidos.svg',
        'Pedidos',
        navBarItemsInfo.length,
      ),
    );

    pages.add(const ProfileScreen());
    navBarItemsInfo.add(
      _NavBarItemInfo(
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
    return Scaffold(
      appBar: _buildCustomHeader(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  String fotoUrl = 'assets/foto-perfil.png';

  PreferredSizeWidget _buildCustomHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    final perfilIndex = _navBarItemsInfo.indexWhere(
                      (item) => item.label == 'Perfil',
                    );
                    if (perfilIndex != -1) {
                      setState(() {
                        _selectedIndex = perfilIndex;
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: (fotoUrl.isNotEmpty)
                        ? AssetImage(fotoUrl)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: (fotoUrl.isEmpty)
                        ? Icon(Icons.person, size: 20, color: Colors.grey[600])
                        : null,
                  ),
                ),

                const Text(
                  'SISTEMA ALMOX',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: brandBlue,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: brandBlue),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(24),
            offset: const Offset(0, -1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navBarItemsInfo.map((item) {
              return _buildNavItem(item.imagePath, item.label, item.index);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String imagePath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color iconColor = isSelected ? brandBlue : text40;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? brandBlueLight : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(
                imagePath,
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? brandBlue : text40,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
