import 'package:flutter/material.dart';
import 'package:sistema_almox/services/sector_service.dart';
import 'package:sistema_almox/services/supplier_service.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupplierFormHandler with ChangeNotifier {
  final Map<String, dynamic>? _supplierToEdit;
  final bool isEditMode;

  final formKey = GlobalKey<FormState>();
  bool hasSubmitted = false;

  final nameController = TextEditingController();
  final cnpjController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final newItemController = TextEditingController();

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  List<String> _items = [];
  List<String> get items => _items;

  List<Map<String, dynamic>> _availableSectors = [];
  List<Map<String, dynamic>> get availableSectors => _availableSectors;

  int? _selectedSectorId;
  int? get selectedSectorId => _selectedSectorId;

  SupplierFormHandler(this._supplierToEdit)
      : isEditMode = _supplierToEdit != null;

  Future<void> initialize() async {
    await _loadSectors();
    if (isEditMode) {
      _populateFormForEdit();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    cnpjController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    newItemController.dispose();
    super.dispose();
  }

  Future<void> _loadSectors() async {
    try {
      _availableSectors = await SectorService().fetchAllSectors();
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar setores: $e');
    }
  }

  void _populateFormForEdit() {
    final supplier = _supplierToEdit!;
    nameController.text = supplier['frn_nome']?.toString() ?? '';
    cnpjController.text = formatCNPJ(supplier['frn_cnpj']?.toString() ?? '');
    telefoneController.text =
        formatPhone(supplier['frn_telefone']?.toString() ?? '');
    emailController.text = supplier['frn_email']?.toString() ?? '';
    _items = List<String>.from(supplier['frn_item'] ?? []);

    final setorId = supplier['frn_setor_id'];
    if (setorId != null &&
        setorId is int &&
        _availableSectors.any((s) => s['id'] == setorId)) {
      _selectedSectorId = setorId;
    }

    notifyListeners();
  }

  Map<String, dynamic> _buildSupplierPayload() {
    if (_selectedSectorId == null) {
      throw Exception('Você precisa selecionar um setor.');
    }

    return {
      'frn_nome': nameController.text.trim(),
      'frn_cnpj': cnpjController.text.replaceAll(RegExp(r'[^\d]'), ''),
      'frn_telefone': telefoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
      'frn_email': emailController.text.trim(),
      'frn_item': _items,
      'frn_setor_id': _selectedSectorId,
    };
  }

  Future<void> save(BuildContext context) async {
    if (isEditMode) {
      await _updateSupplier(context);
    } else {
      await _registerSupplier(context);
    }
  }

  Future<void> _registerSupplier(BuildContext context) async {
    FocusScope.of(context).unfocus();
    hasSubmitted = true;
    notifyListeners();

    if (!(formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    _setSaving(true);

    try {
      final supplierPayload = _buildSupplierPayload();
      await SupplierService.instance.createSupplier(supplierPayload);
      showCustomSnackbar(context, 'Fornecedor cadastrado com sucesso!');
      if (context.mounted) Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      _handlePostgrestError(context, e);
    } catch (e) {
      if (context.mounted) showCustomSnackbar(context, e.toString(), isError: true);
    } finally {
      _setSaving(false);
    }
  }

  Future<void> _updateSupplier(BuildContext context) async {
    FocusScope.of(context).unfocus();
    hasSubmitted = true;
    notifyListeners();

    if (!(formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    _setSaving(true);

    try {
      final supplierPayload = _buildSupplierPayload();
      final supplierId = _supplierToEdit?['id'];
      if (supplierId == null) {
        throw Exception('ID do fornecedor para edição não foi encontrado.');
      }

      await SupplierService.instance.updateSupplier(supplierId as int, supplierPayload);
      showCustomSnackbar(context, 'Fornecedor atualizado com sucesso!');
      if (context.mounted) Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      _handlePostgrestError(context, e);
    } catch (e) {
      if (context.mounted) {
        showCustomSnackbar(
          context,
          'Ocorreu um erro ao atualizar o fornecedor. Tente novamente.',
          isError: true,
        );
      }
    } finally {
      _setSaving(false);
    }
  }

  Future<void> deactivateSupplier(BuildContext context) async {
    final supplierId = _supplierToEdit?['id'];
    if (supplierId == null) {
      showCustomSnackbar(
        context,
        'ID do fornecedor inválido. Não é possível excluir.',
        isError: true,
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja desativar este fornecedor?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    _setSaving(true);
    try {
      await SupplierService.instance.deactivateSupplier(supplierId as int);
      if (context.mounted) {
        showCustomSnackbar(context, 'Fornecedor desativado com sucesso!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackbar(context, e.toString(), isError: true);
      }
    } finally {
      _setSaving(false);
    }
  }

  void _setSaving(bool saving) {
    if (_isSaving != saving) {
      _isSaving = saving;
      notifyListeners();
    }
  }

  void _handlePostgrestError(BuildContext context, PostgrestException e) {
    if (e.message.contains('supplier_cnpj_key')) {
      showCustomSnackbar(
        context,
        'O CNPJ informado já está em uso.',
        isError: true,
      );
    } else {
      showCustomSnackbar(
        context,
        'Erro no banco de dados: ${e.message}',
        isError: true,
      );
    }
  }

  void addItem() {
    final newItem = newItemController.text.trim();
    if (newItem.isNotEmpty && !_items.contains(newItem)) {
      _items.add(newItem);
      newItemController.clear();
      notifyListeners();
    }
  }

  void removeItem(String item) {
    _items.remove(item);
    notifyListeners();
  }

  void setSelectedSector(int? sectorId) {
    _selectedSectorId = sectorId;
    notifyListeners();
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 10 || digits.length > 11) {
      return 'Telefone inválido';
    }
    return null;
  }

  String? validateCnpj(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length != 14) {
      return 'CNPJ inválido';
    }
    return null;
  }

  String formatCNPJ(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length > 12) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
    } else if (digits.length > 8) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8)}';
    } else if (digits.length > 5) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5)}';
    } else if (digits.length > 2) {
      return '${digits.substring(0, 2)}.${digits.substring(2)}';
    }
    return digits;
  }

  String formatPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    } else if (digits.length > 6) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    } else if (digits.length > 2) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2)}';
    }
    return digits;
  }

  void formatAndSetCnpj(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    final limitedDigits = digits.length > 14 ? digits.substring(0, 14) : digits;
    final formatted = formatCNPJ(limitedDigits);

    if (cnpjController.text != formatted) {
      cnpjController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void formatAndSetPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    final limitedDigits = digits.length > 11 ? digits.substring(0, 11) : digits;
    final formatted = formatPhone(limitedDigits);

    if (telefoneController.text != formatted) {
      telefoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}