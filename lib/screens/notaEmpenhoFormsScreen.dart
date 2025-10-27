import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotaEmpenhoFormScreen extends StatefulWidget {
  final Map<String, dynamic>? nota; 

  const NotaEmpenhoFormScreen({super.key, this.nota});

  @override
  State<NotaEmpenhoFormScreen> createState() => _NotaEmpenhoFormScreenState();
}

class _NotaEmpenhoFormScreenState extends State<NotaEmpenhoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _neController = TextEditingController();
  final _favorecidoController = TextEditingController();
  final _itemController = TextEditingController();
  final _diasController = TextEditingController();
  final _saldoController = TextEditingController();
  final _justificativaController = TextEditingController();
  final _dataTextController = TextEditingController();

  DateTime _dataController = DateTime.now();

  bool processoAdmSim = false;
  bool processoAdmNao = true;
  bool materialRecebidoSim = false;
  bool materialRecebidoNao = true;
  bool nfEntregueSim = false;
  bool nfEntregueNao = true;
  bool enviadoLiquidarSim = false;
  bool enviadoLiquidarNao = true;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final nota = widget.nota;

    try {
      if (nota != null) {
        _neController.text = nota['NE']?.toString() ?? '';
        _favorecidoController.text = nota['favorecido']?.toString() ?? '';
        _itemController.text = nota['item']?.toString() ?? '';
        _diasController.text = nota['dias']?.toString() ?? '';
        _saldoController.text = nota['saldo']?.toString() ?? '';
        _justificativaController.text = nota['justificativa_atraso']?.toString() ?? '';

        if (nota['data'] != null && nota['data'] is String && nota['data'].toString().trim().isNotEmpty) {
          final dataStr = nota['data'].toString().trim();
          _dataTextController.text = dataStr;
          try {
            final parts = dataStr.split('/');
            if (parts.length == 3) {
              _dataController = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            } else {
              try {
                _dataController = DateTime.parse(dataStr);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Formato de data inválido.')),
                );
              }
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao processar a data: $e')),
            );
          }
        } else {
          _dataTextController.text = '';
        }

        processoAdmSim = (nota['processo_adm']?.toString().toLowerCase() == 'sim');
        processoAdmNao = !processoAdmSim;
        materialRecebidoSim = (nota['material_recebido']?.toString().toLowerCase() == 'sim');
        materialRecebidoNao = !materialRecebidoSim;
        nfEntregueSim = (nota['nf_entregue_no_almox']?.toString().toLowerCase() == 'sim');
        nfEntregueNao = !nfEntregueSim;
        enviadoLiquidarSim = (nota['enviado_para_liquidar']?.toString().toLowerCase() == 'sim');
        enviadoLiquidarNao = !enviadoLiquidarSim;

        _atualizarSaldo();
      } else {
        _neController.text = '';
        _favorecidoController.text = '';
        _itemController.text = '';
        _diasController.text = '';
        _saldoController.text = '';
        _justificativaController.text = '';
        _dataController = DateTime.now();
        _dataTextController.text = DateFormat('dd/MM/yyyy').format(_dataController);

        processoAdmSim = false;
        processoAdmNao = true;
        materialRecebidoSim = false;
        materialRecebidoNao = true;
        nfEntregueSim = false;
        nfEntregueNao = true;
        enviadoLiquidarSim = false;
        enviadoLiquidarNao = true;

        _atualizarSaldo();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao inicializar os campos: $e')),
      );
    }
  }

  @override
  void dispose() {
    _neController.dispose();
    _favorecidoController.dispose();
    _itemController.dispose();
    _diasController.dispose();
    _saldoController.dispose();
    _justificativaController.dispose();
    _dataTextController.dispose();
    super.dispose();
  }

  void _atualizarSaldo() {
    try {
      if (_diasController.text.isEmpty) {
        _saldoController.text = _saldoController.text.isNotEmpty ? _saldoController.text : '';
        return;
      }

      final dias = int.tryParse(_diasController.text) ?? 0;
      final agora = DateTime.now();
      final diferenca = _dataController.difference(agora).inDays + dias;
      _saldoController.text = diferenca.toString();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar saldo: $e')),
      );
    }
  }

  Widget _buildCheckRow(
      String label, bool simValue, bool naoValue, void Function() onSim, void Function() onNao) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          spacing: 8,
          children: [
            SizedBox(
              width: constraints.maxWidth > 600 ? 220 : constraints.maxWidth * 0.45,
              child: Text(label, style: const TextStyle(fontSize: 16)),
            ),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Checkbox(value: simValue, onChanged: (_) => onSim()),
              const Text('Sim')
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Checkbox(value: naoValue, onChanged: (_) => onNao()),
              const Text('Não')
            ]),
          ],
        );
      },
    );
  }

  Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    final supabase = Supabase.instance.client;

    final fornecedorNome = _favorecidoController.text;
    final fornecedorCheck = await supabase
        .from('fornecedor')
        .select('frn_nome')
        .eq('frn_nome', fornecedorNome)
        .maybeSingle();
    if (fornecedorCheck == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fornecedor "$fornecedorNome" não encontrado na tabela fornecedor.')),
      );
      setState(() => _isSaving = false);
      return;
    }

    String? dataIso;
    if (_dataTextController.text.isNotEmpty) {
      try {
        final parsedDate = DateFormat('dd/MM/yyyy').parse(_dataTextController.text);
        dataIso = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (_) {
        dataIso = widget.nota?['data']?.toString();
      }
    } else {
      dataIso = widget.nota?['data']?.toString();
    }

    final dados = <String, dynamic>{
      'NE': _neController.text.isNotEmpty ? _neController.text : widget.nota?['NE'],
      'data': dataIso,
      'favorecido': fornecedorNome,
      'dias': _diasController.text.isNotEmpty ? int.tryParse(_diasController.text) : widget.nota?['dias'],
      'saldo': _saldoController.text.isNotEmpty ? int.tryParse(_saldoController.text) : widget.nota?['saldo'],
      'processo_adm': processoAdmSim ? 'Sim' : (processoAdmNao ? 'Não' : widget.nota?['processo_adm']),
      'material_recebido': materialRecebidoSim ? 'Sim' : (materialRecebidoNao ? 'Não' : widget.nota?['material_recebido']),
      'nf_entregue_no_almox': nfEntregueSim ? 'Sim' : (nfEntregueNao ? 'Não' : widget.nota?['nf_entregue_no_almox']),
      'justificativa_atraso': _justificativaController.text.isNotEmpty ? _justificativaController.text : widget.nota?['justificativa_atraso'],
      'enviado_para_liquidar': enviadoLiquidarSim ? 'Sim' : (enviadoLiquidarNao ? 'Não' : widget.nota?['enviado_para_liquidar']),
      'item': _itemController.text.isNotEmpty ? _itemController.text : widget.nota?['item'],
    };

    // 4️⃣ Salvar
    if (widget.nota != null && widget.nota!['id'] != null) {
      await supabase.from('nota_empenho').update(dados).eq('id', widget.nota!['id']);
    } else {
      await supabase.from('nota_empenho').insert(dados);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Nota salva com sucesso!')));
      Navigator.pop(context, true);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar nota: $e')),
      );
    }
  } finally {
    if (mounted) setState(() => _isSaving = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nota != null ? 'Editar Nota de Empenho' : 'Nova Nota de Empenho')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _neController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'NE',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _favorecidoController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Favorecido',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200], 
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _itemController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Item',
                      labelStyle: TextStyle(
                        color: Colors.grey[600], 
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200], 
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dataTextController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Data',
                      labelStyle: TextStyle(
                        color: Colors.grey[600], 
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200], 
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: isWide ? 1 : 2,
                        child: TextFormField(
                          controller: _diasController,
                          decoration: const InputDecoration(labelText: 'Dias para entrega', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(_atualizarSaldo),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _saldoController,
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Saldo (dias)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCheckRow('Processo Adm:', processoAdmSim, processoAdmNao, () => setState(() { processoAdmSim = true; processoAdmNao = false; }), () => setState(() { processoAdmSim = false; processoAdmNao = true; })),
                  const SizedBox(height: 8),
                  _buildCheckRow('Material Recebido:', materialRecebidoSim, materialRecebidoNao, () => setState(() { materialRecebidoSim = true; materialRecebidoNao = false; }), () => setState(() { materialRecebidoSim = false; materialRecebidoNao = true; })),
                  const SizedBox(height: 8),
                  _buildCheckRow('NF Entregue no Almox:', nfEntregueSim, nfEntregueNao, () => setState(() { nfEntregueSim = true; nfEntregueNao = false; }), () => setState(() { nfEntregueSim = false; nfEntregueNao = true; })),
                  const SizedBox(height: 8),
                  _buildCheckRow('Enviado para Liquidar:', enviadoLiquidarSim, enviadoLiquidarNao, () => setState(() { enviadoLiquidarSim = true; enviadoLiquidarNao = false; }), () => setState(() { enviadoLiquidarSim = false; enviadoLiquidarNao = true; })),
                  const SizedBox(height: 12),
                  TextFormField(controller: _justificativaController, decoration: const InputDecoration(labelText: 'Justificativa de atraso', border: OutlineInputBorder()), maxLines: 3),
                  const SizedBox(height: 20),
                  Center(
                    child: _isSaving
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 20, vertical: 14),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
