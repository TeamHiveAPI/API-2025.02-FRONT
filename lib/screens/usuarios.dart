
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/cards/lieutenant.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<Map<String, dynamic>> _almoxarifeFuture;
  late Future<Map<String, dynamic>> _farmaciaFuture;

  final _userService = UserService.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _almoxarifeFuture = _userService.fetchLieutenant(accessLevel: 2, sectorId: 1);
    _farmaciaFuture = _userService.fetchLieutenant(accessLevel: 2, sectorId: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InternalPageHeader(title: 'Listagem de Usuários'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildLieutenantCard(
                      future: _almoxarifeFuture,
                      title: 'Tenente Almoxarifado',
                    ),
                    const SizedBox(height: 20),
                    _buildLieutenantCard(
                      future: _farmaciaFuture,
                      title: 'Tenente Farmácia',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLieutenantCard({
    required Future<Map<String, dynamic>> future,
    required String title,
  }) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return ShimmerPlaceholder(height: 120);
        }
        if (userSnapshot.hasError) {
          return Center(child: Text('Erro: ${userSnapshot.error}'));
        }
        if (userSnapshot.hasData) {
          final userData = userSnapshot.data!;
          final userName = userData['usr_nome'] as String;
          final photoPath = userData['usr_foto_url'] as String? ?? '';
          
          final lastModifiedString = userData['usr_ultima_modificacao'] as String?;
          String formattedDate = 'Data não disponível';
          if (lastModifiedString != null) {
            try {
              final dateTime = DateTime.parse(lastModifiedString);
              formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
            } catch (e) {
              print("Erro ao formatar data: $e");
            }
          }
          
          final displayDate = 'Desde $formattedDate';

          return FutureBuilder<String>(
            future: _userService.createSignedUrlForAvatar(photoPath),
            builder: (context, urlSnapshot) {
              final imageUrl = (urlSnapshot.data ?? '').isNotEmpty
                  ? urlSnapshot.data!
                  : 'assets/images/default_avatar.png';

              return LieutenantCard(
                title: title,
                name: formatName(userName),
                date: displayDate,
                imageUrl: imageUrl,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}