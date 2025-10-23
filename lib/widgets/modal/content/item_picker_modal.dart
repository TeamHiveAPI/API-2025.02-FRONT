import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/services/pedido_service.dart';

class ItemPickerResult {
  final List<SelectedItem> items;
  ItemPickerResult(this.items);
}

class _MaxValueTextInputFormatter extends TextInputFormatter {
  final int max;
  const _MaxValueTextInputFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue.copyWith(text: '');
    final value = int.tryParse(text);
    if (value == null) return oldValue;
    if (value > max) {
      final capped = max.toString();
      return TextEditingValue(
        text: capped,
        selection: TextSelection.collapsed(offset: capped.length),
      );
    }
    return newValue;
  }
}

class SelectedLot {
  final int loteId;
  int quantidade;
  final int disponivel;
  final String? codigo;
  final String? validade;
  SelectedLot({required this.loteId, required this.quantidade, required this.disponivel, this.codigo, this.validade});
}

class SelectedItem {
  final int itemId;
  final String nome;
  final String unidade;
  int quantidadeTotal;
  final List<SelectedLot> lotes;
  SelectedItem({
    required this.itemId,
    required this.nome,
    required this.unidade,
    this.quantidadeTotal = 0,
    List<SelectedLot>? lotes,
  }) : lotes = lotes ?? [];
}

class ItemPickerModal extends StatefulWidget {
  final List<SelectedItem>? initialSelection;
  const ItemPickerModal({super.key, this.initialSelection});

  static Future<ItemPickerResult?> show(BuildContext context, {List<SelectedItem>? initialSelection}) async {
    return await showModalBottomSheet<ItemPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ItemPickerModal(initialSelection: initialSelection),
    );
  }

  @override
  State<ItemPickerModal> createState() => _ItemPickerModalState();
}

class _ItemPickerModalState extends State<ItemPickerModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  final Map<int, SelectedItem> _selected = {};
  final Map<int, bool> _loadingLots = {};

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    if (widget.initialSelection != null && widget.initialSelection!.isNotEmpty) {
      for (final sel in widget.initialSelection!) {
        _selected[sel.itemId] = SelectedItem(
          itemId: sel.itemId,
          nome: sel.nome,
          unidade: sel.unidade,
          quantidadeTotal: sel.quantidadeTotal,
          lotes: sel.lotes
              .map((l) => SelectedLot(
                    loteId: l.loteId,
                    quantidade: l.quantidade,
                    disponivel: l.disponivel,
                    codigo: l.codigo,
                    validade: l.validade,
                  ))
              .toList(),
        );
      }
    }
    _load();
  }

  void _onSearchChanged() {
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await PedidoService.instance.getAvailableItems(
        searchQuery: _searchCtrl.text.trim(),
      );
      _items = items;
    } catch (_) {
      _items = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _loadLotes(int itemId) async {
    return await PedidoService.instance.getLotesPorItem(itemId);
  }

  int _enabledLotsCount(SelectedItem s) {
    for (int i = 0; i < s.lotes.length; i++) {
      final lot = s.lotes[i];
      final max = lot.disponivel;
      final isFull = max <= 0 || lot.quantidade >= max;
      if (!isFull) {
        return i + 1;
      }
    }
    return s.lotes.length;
  }

  Future<void> _toggleItem(Map<String, dynamic> item) async {
    final int id = item['id'] as int;
    if (_selected.containsKey(id)) {
      setState(() => _selected.remove(id));
      return;
    }
    final sel = SelectedItem(
      itemId: id,
      nome: (item['nome'] ?? item[ItemFields.nome]).toString(),
      unidade: (item['unidade'] ?? item[ItemFields.unidade]).toString(),
    );

    setState(() => _loadingLots[id] = true);
    final lotes = await _loadLotes(id);
    setState(() => _loadingLots[id] = false);

    if (lotes.length > 1) {
      sel.lotes.addAll(lotes.map((l) => SelectedLot(
            loteId: l['id'] as int,
            quantidade: 0,
            disponivel: ((l['disponivel'] ?? (((l['qtd_atual'] ?? 0) as num).toInt() - ((l['qtd_reservada'] ?? 0) as num).toInt())) as num).toInt(),
            codigo: l['codigo_lote']?.toString(),
            validade: l['data_validade']?.toString(),
          )));
    } else if (lotes.length == 1) {
      final l = lotes.first;
      sel.lotes.add(SelectedLot(
        loteId: l['id'] as int,
        quantidade: 0,
        disponivel: ((l['disponivel'] ?? (((l['qtd_atual'] ?? 0) as num).toInt() - ((l['qtd_reservada'] ?? 0) as num).toInt())) as num).toInt(),
        codigo: l['codigo_lote']?.toString(),
        validade: l['data_validade']?.toString(),
      ));
    }

    setState(() => _selected[id] = sel);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(height: 4, width: 48, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),
              const Text('Selecionar Itens', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar item...'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Builder(
                        builder: (context) {
                          final query = _searchCtrl.text.toLowerCase();
                          final visibleItems = _items.where((it) {
                            final String nome = (it['nome'] ?? it[ItemFields.nome]).toString();
                            return query.isEmpty || nome.toLowerCase().contains(query);
                          }).toList();

                          if (visibleItems.isEmpty) {
                            final bool isSearching = query.isNotEmpty;
                            final String message = isSearching
                                ? 'Nenhum item encontrado para a busca.'
                                : 'Nenhum item disponível para este setor.';
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  message,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: visibleItems.length,
                            itemBuilder: (context, index) {
                              final it = visibleItems[index];
                              final String nome = (it['nome'] ?? it[ItemFields.nome]).toString();
                              final int id = it['id'] as int;
                              final bool selected = _selected.containsKey(id);
                              final loadingLots = _loadingLots[id] == true;
                              final sel = _selected[id];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(nome),
                                    subtitle: Text((it['unidade'] ?? it[ItemFields.unidade]).toString()),
                                    trailing: Checkbox(value: selected, onChanged: (_) => _toggleItem(it)),
                                    onTap: () => _toggleItem(it),
                                  ),
                                  if (selected)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: loadingLots
                                          ? const Center(child: CircularProgressIndicator())
                                          : Column(
                                              children: [
                                                if (sel!.lotes.length > 1) ...List.generate(sel.lotes.length, (idx) {
                                                  final lotSel = sel.lotes[idx];
                                                  final disp = lotSel.disponivel;
                                                  final enabledCount = _enabledLotsCount(sel);
                                                  final isEnabled = idx < enabledCount;
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 10.0),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('${lotSel.codigo ?? 'Lote'} • Disp: $disp'),
                                                              if ((lotSel.validade != null) && lotSel.validade!.toString().isNotEmpty)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 2.0),
                                                                  child: Text(
                                                                    'Val: ${lotSel.validade}',
                                                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                                  ),
                                                                ),
                                                              if (!isEnabled)
                                                                const Padding(
                                                                  padding: EdgeInsets.only(top: 2.0),
                                                                  child: Text(
                                                                    'Preencha o lote anterior primeiro',
                                                                    style: TextStyle(fontSize: 11, color: Colors.black45),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 90,
                                                          child: TextFormField(
                                                            initialValue: lotSel.quantidade.toString(),
                                                            enabled: isEnabled,
                                                            keyboardType: TextInputType.number,
                                                            decoration: const InputDecoration(isDense: true, labelText: 'Qtd'),
                                                            inputFormatters: isEnabled
                                                                ? [
                                                                    FilteringTextInputFormatter.digitsOnly,
                                                                    _MaxValueTextInputFormatter(disp),
                                                                  ]
                                                                : [FilteringTextInputFormatter.digitsOnly],
                                                            onChanged: (v) {
                                                              final q = int.tryParse(v) ?? 0;
                                                              setState(() {
                                                                lotSel.quantidade = q.clamp(0, disp);
                                                                final newEnabled = _enabledLotsCount(sel);
                                                                for (int j = newEnabled; j < sel.lotes.length; j++) {
                                                                  if (sel.lotes[j].quantidade != 0) {
                                                                    sel.lotes[j].quantidade = 0;
                                                                  }
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                                if (sel.lotes.length == 1) ...[
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(bottom: 8.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '${sel.lotes.first.codigo ?? 'Lote'} • Disp: ${sel.lotes.first.disponivel}',
                                                          ),
                                                          if ((sel.lotes.first.validade != null) && sel.lotes.first.validade!.toString().isNotEmpty)
                                                            const SizedBox(height: 2),
                                                          if ((sel.lotes.first.validade != null) && sel.lotes.first.validade!.toString().isNotEmpty)
                                                            const Text(
                                                              // The validity value itself is shown below with styling
                                                              '',
                                                            ),
                                                          if ((sel.lotes.first.validade != null) && sel.lotes.first.validade!.toString().isNotEmpty)
                                                            Text(
                                                              'Val: ${sel.lotes.first.validade}',
                                                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Text('Quantidade:'),
                                                      const SizedBox(width: 8),
                                                      SizedBox(
                                                        width: 120,
                                                        child: TextFormField(
                                                          initialValue: sel.quantidadeTotal.toString(),
                                                          keyboardType: TextInputType.number,
                                                          decoration: InputDecoration(
                                                            isDense: true,
                                                            labelText: 'Qtd',
                                                            suffixText: 'max ${sel.lotes.first.disponivel}',
                                                          ),
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.digitsOnly,
                                                            _MaxValueTextInputFormatter(sel.lotes.first.disponivel),
                                                          ],
                                                          onChanged: (v) {
                                                            final q = int.tryParse(v) ?? 0;
                                                            final max = sel.lotes.first.disponivel;
                                                            setState(() => sel.quantidadeTotal = q.clamp(0, max));
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]
                                                else if (sel.lotes.isEmpty) Row(
                                                  children: [
                                                    const Text('Quantidade:'),
                                                    const SizedBox(width: 8),
                                                    SizedBox(
                                                      width: 100,
                                                      child: TextFormField(
                                                        initialValue: sel.quantidadeTotal.toString(),
                                                        keyboardType: TextInputType.number,
                                                        onChanged: (v) {
                                                          final q = int.tryParse(v) ?? 0;
                                                          setState(() => sel.quantidadeTotal = q.clamp(0, 100000));
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                    ),
                                  const Divider(height: 1),
                                ],
                              );
                            },
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selected.isEmpty
                            ? null
                            : () {
                                final list = _selected.values
                                    .where((s) {
                                      if (s.lotes.length > 1) {
                                        final total = s.lotes.fold<int>(0, (acc, l) => acc + l.quantidade);
                                        return total > 0;
                                      }
                                      return s.quantidadeTotal > 0;
                                    })
                                    .map((s) {
                                      if (s.lotes.length == 1) {
                                        s.lotes.first.quantidade = s.quantidadeTotal;
                                      }
                                      return s;
                                    })
                                    .toList();
                                if (list.isEmpty) {
                                  return;
                                }
                                Navigator.of(context).pop(ItemPickerResult(list));
                              },
                        child: const Text('Adicionar'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
