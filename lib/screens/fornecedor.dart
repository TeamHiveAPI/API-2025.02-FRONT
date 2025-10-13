import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/screens/novo_fornecedor/index.dart'; 
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/data_table/content/supplier_list.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/main_scaffold/header.dart';

class FornecedorScreen extends StatefulWidget {
  const FornecedorScreen({super.key});

  @override
  State<FornecedorScreen> createState() => _FornecedorScreenState();
}

class _FornecedorScreenState extends State<FornecedorScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _refreshCounter = 0; 

  @override
  void initState() {
    super.initState();
    UserService.instance.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    UserService.instance.removeListener(_onUserChanged);
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

  void _navigateToNewSupplierScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewSupplierScreen()),
    ).then((_) {
      
      _reloadSupplierList();
    });
  }

  
  void _reloadSupplierList() {
    setState(() {
      _refreshCounter++; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService.instance;
    final currentUserRole = userService.currentUser!.role;

    return Scaffold(
      appBar: CustomHeader(
        onProfileTap: (index) {
          
          print('Perfil tocado, índice: $index');
        },
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            CustomButton(
              text: 'Cadastrar Novo Fornecedor',
              icon: Icons.add,
              widthPercent: 1.0,
              onPressed: () {
                _navigateToNewSupplierScreen(context); 
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Listagem de Fornecedores',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: text40,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GenericSearchInput(
                    controller: _searchController,
                    onSearchChanged: _handleSearch,
                  ),
                ),
                SizedBox(width: 20),
                CustomButton(
                  icon: Icons.refresh,
                  squareMode: true,
                  onPressed: _reloadSupplierList,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            SupplierList(
              key: ValueKey('supplier_list_${_refreshCounter}_${_searchQuery}'),
              searchQuery: _searchQuery,
              userRole: currentUserRole,
            ),
          ],
        ),
      ),
    );
  }
}