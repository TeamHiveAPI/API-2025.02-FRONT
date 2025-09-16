import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class NavBarItemInfo {
  final String imagePath;
  final String label;
  final int index;

  NavBarItemInfo(this.imagePath, this.label, this.index);
}

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<NavBarItemInfo> navBarItemsInfo;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.navBarItemsInfo,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
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
            children: navBarItemsInfo.map((item) {
              return _buildNavItem(item.imagePath, item.label, item.index, context);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String imagePath, String label, int index, BuildContext context) {
    final bool isSelected = selectedIndex == index;
    final Color iconColor = isSelected ? brandBlue : text40;

    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
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