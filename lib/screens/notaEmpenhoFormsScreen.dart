import 'package:flutter/material.dart';
import 'package:sistema_almox/services/criar_empenho.dart';
import 'package:sistema_almox/services/item_service.dart';
import 'package:sistema_almox/services/fornecedor_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class NotaEmpenhoFormScreen extends StatefulWidget {
  final Map<String, dynamic>? nota;
  const NotaEmpenhoFormScreen({super.key, this.nota});

  @override
  State<NotaEmpenhoFormScreen> createState() => _NotaEmpenhoFormScreenState();
}

class _NotaEmpenhoFormScreenState extends State<NotaEmpenhoFormScreen> {
  final _service = NotaEmpenhoService();
  final _fornecedorService = FornecedorService();
  final _itemService = ItemService.instance;

  final _neController = TextEditingController();
  final _favorecidoController = TextEditingController();
  final _processoController = TextEditingController();
  final _materialController = TextEditingController();
  final _nfController = TextEditingController();
  final _justificativaController = TextEditingController();
  final _enviadoController = TextEditingController();
  final _itemController = TextEditingController();
  final _diasController = TextEditingController();
  final _saldoController = TextEditingController();

  DateTime _data = DateTime.now();

  List<String> _fornecedores = [];
  List<String> _itens = [];

  @override
  void initState() {
    super.initState();
    _carregarFornecedores();
    _carregarItens();

    if (widget.nota != null) {
      final nota = widget.nota!;
      _neController.text = nota['NE'] ?? '';
      _data = nota['data'] != null
          ? DateTime.tryParse(nota['data'].toString()) ?? DateTime.now()
          : DateTime.now();
      _favorecidoController.text = nota['favorecido'] ?? '';
      _processoController.text = nota['processo_adm'] ?? '';
      _materialController.text = nota['material_recebido'] ?? '';
      _nfController.text = nota['nf_entregue_no_almox'] ?? '';
      _justificativaController.text = nota['justificativa_atraso'] ?? '';
      _enviadoController.text = nota['enviado_para_liquidar'] ?? '';
      _itemController.text = nota['item'] ?? '';
      _diasController.text = nota['dias']?.toString() ?? '';
      _saldoController.text = nota['saldo']?.toString() ?? '';
    } else {
      _data = DateTime.now();
    }
  }

  Future<void> _carregarFornecedores() async {
    final lista = await _fornecedorService.fetchFornecedores();
    setState(() {
      _fornecedores = lista;
    });
  }

  Future<void> _carregarItens() async {
    final lista = await _itemService.fetchItensNomes();
    setState(() {
      _itens = lista;
    });
  }

  Future<void> _save() async {
    if (_neController.text.isEmpty || _favorecidoController.text.isEmpty) {
      showCustomSnackbar(context, 'Preencha os campos obrigatórios!', isError: true);
      return;
    }

    if (!_fornecedores.contains(_favorecidoController.text.trim())) {
      showCustomSnackbar(context, 'O favorecido deve ser um fornecedor válido!', isError: true);
      return;
    }

    if (!_itens.contains(_itemController.text.trim())) {
      showCustomSnackbar(context, 'O item deve ser válido!', isError: true);
      return;
    }

    final data = {
      'NE': _neController.text,
      'data': _data.toIso8601String(),
      'favorecido': _favorecidoController.text,
      'dias': _diasController.text.isNotEmpty ? int.tryParse(_diasController.text) : null,
      'saldo': _saldoController.text.isNotEmpty ? double.tryParse(_saldoController.text) : null,
      'processo_adm': _processoController.text,
      'material_recebido': _materialController.text,
      'nf_entregue_no_almox': _nfController.text,
      'justificativa_atraso': _justificativaController.text,
      'enviado_para_liquidar': _enviadoController.text,
      'item': _itemController.text,
    };

    if (widget.nota == null) {
      await _service.createNota(data);
      showCustomSnackbar(context, 'Nota criada com sucesso!');
    } else {
      await _service.updateNota(widget.nota!['id'], data);
      showCustomSnackbar(context, 'Nota atualizada com sucesso!');
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nota == null ? 'Nova Nota de Empenho' : 'Editar Nota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _neController, decoration: const InputDecoration(labelText: 'NE')),

            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return _fornecedores.where((f) =>
                    f.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                _favorecidoController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                controller.text = _favorecidoController.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Favorecido'),
                  onChanged: (value) => _favorecidoController.text = value,
                );
              },
            ),

            TextField(controller: _processoController, decoration: const InputDecoration(labelText: 'Processo Adm')),
            TextField(controller: _materialController, decoration: const InputDecoration(labelText: 'Material Recebido')),
            TextField(controller: _nfController, decoration: const InputDecoration(labelText: 'NF Entregue no Almox')),
            TextField(controller: _justificativaController, decoration: const InputDecoration(labelText: 'Justificativa de Atraso')),
            TextField(controller: _enviadoController, decoration: const InputDecoration(labelText: 'Enviado para Liquidar')),

            /// --- Autocomplete para item ---
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return _itens.where((i) =>
                    i.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                _itemController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                controller.text = _itemController.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Item',
                    hintText: 'Digite ou selecione um item existente',
                  ),
                  onChanged: (value) => _itemController.text = value,
                );
              },
            ),

            TextField(
              controller: _diasController,
              decoration: const InputDecoration(labelText: 'Dias'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _saldoController,
              decoration: const InputDecoration(labelText: 'Saldo'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),

            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Data',
                hintText: '${_data.day}/${_data.month}/${_data.year}',
              ),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _data,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _data = pickedDate;
                  });
                }
              },
            ),

            const SizedBox(height: 20),
            CustomButton(text: 'Salvar', icon: Icons.save, onPressed: _save),
          ],
        ),
      ),
    );
  } 
}
