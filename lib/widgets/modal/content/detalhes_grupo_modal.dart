import 'package:flutter/material.dart';
import 'package:sistema_almox/services/group_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';

class DetalhesGrupoModal extends StatefulWidget {
  final int groupId;
  final String groupName;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DetalhesGrupoModal({
    super.key,
    required this.groupId,
    required this.groupName,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<DetalhesGrupoModal> createState() => _DetalhesGrupoModalState();
}

class _DetalhesGrupoModalState extends State<DetalhesGrupoModal> {
  bool _isLoadingInitialContent = true;
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final count = await GroupService().countItemsInGroup(widget.groupId);

      if (mounted) {
        setState(() {
          _itemCount = count;
          _isLoadingInitialContent = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _itemCount = 0;
          _isLoadingInitialContent = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DetailItemCard(
          isLoading: false,
          label: "NOME",
          value: widget.groupName,
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: DetailItemCard(
                isLoading: false,
                label: "IDENTIFICAÇÃO",
                value: widget.groupId.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(
                isLoading: _isLoadingInitialContent,
                label: "ITENS VINCULADOS",
                value: _itemCount.toString(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        CustomButton(
          text: "Editar",
          customIcon: "assets/icons/edit.svg",
          onPressed:
              widget.onEdit ??
              () {
                Navigator.pop(context, 'edit');
              },
          isFullWidth: true,
        ),
      ],
    );
  }
}
