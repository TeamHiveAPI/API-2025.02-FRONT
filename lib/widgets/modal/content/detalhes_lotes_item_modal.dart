import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/data_table/content/item_lots_list.dart';

class LotesItemModal extends StatelessWidget {
  final int itemId;

  const LotesItemModal({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 230,
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: ItemLotesTable(itemId: itemId),
        ),
      ),
    );
  }
}