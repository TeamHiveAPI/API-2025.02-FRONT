import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/data_table/content/pedidos_list.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _searchQuery = '';
  final currentUser = UserService.instance.currentUser;

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  UserRole get _currentUserRole =>
      UserService.instance.currentUser?.role ?? UserRole.soldadoComum;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const InternalPageHeader(title: 'Histórico de Pedidos'),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: brightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: FutureBuilder<String>(
                            future: UserService.instance.getSignedAvatarUrl(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.person, color: Colors.grey[600]),
                                );
                              }
                              return CachedNetworkImage(
                                imageUrl: snapshot.data!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const ShimmerPlaceholder.circle(radius: 25),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.person, color: Colors.grey[600]),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "USUÁRIO",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: text80,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (currentUser?.nome ?? 'Usuário').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: text40,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: GenericSearchInput(
                        onSearchChanged: _handleSearch,
                        hintText: 'Pesquisar',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SafeArea(
              top: false,
              bottom: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    PedidosTable(
                      key: const ValueKey('meus_pedidos'),
                      searchQuery: _searchQuery,
                      userRole: _currentUserRole,
                      onlyMyOrders: true,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}