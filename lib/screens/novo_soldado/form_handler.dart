import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterSoldierFormHandler with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  bool hasSubmitted = false;

  final nameController = TextEditingController();
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final sectorController = TextEditingController();

  final cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  final _userService = UserService.instance;

  void init(Map<String, dynamic>? soldierToEdit) {
    if (soldierToEdit != null) {
      nameController.text = soldierToEdit[UsuarioFields.nome] ?? '';
      cpfController.text = soldierToEdit[UsuarioFields.cpf] ?? '';
      emailController.text = soldierToEdit[UsuarioFields.email] ?? '';
      // TODO: Lógica pra carregar foto
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 70,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajuste sua Foto',
          toolbarColor: brandBlue,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
        ),
        IOSUiSettings(title: 'Ajuste sua Foto'),
      ],
    );

    if (croppedFile == null) return;

    _selectedImage = XFile(croppedFile.path);
    notifyListeners();
  }

  Future<void> registerSoldier(BuildContext context, XFile? avatarFile) async {
    FocusScope.of(context).unfocus();
    hasSubmitted = true;
    notifyListeners();

    if (!(formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final viewingSectorId = _userService.viewingSectorId;
      if (viewingSectorId == null) {
        throw Exception('Setor de visualização não definido.');
      }

      final userResponse = await Supabase.instance.client.functions.invoke(
        'create-user-soldier',
        body: {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'cpf': cpfMaskFormatter.getUnmaskedText(),
          'viewingSectorId': viewingSectorId,
        },
      );

      if (userResponse.status != 200) {
        throw Exception(
          userResponse.data['error'] ?? 'Falha ao criar soldado.',
        );
      }

      final Map<String, dynamic> userData = userResponse.data;
      final String? newPassword = userData['password'] as String?;
      final String? newUserId = userData['userId'] as String?;

      if (newPassword == null || newUserId == null) {
        throw Exception(
          'Resposta da API inválida: não foi possível obter a senha ou o ID do novo usuário.',
        );
      }

      String? finalAvatarUrl;

      if (avatarFile != null) {
        final signedUrlResponse = await Supabase.instance.client.functions
            .invoke('create-signed-avatar-url', body: {'userId': newUserId});

        if (signedUrlResponse.status != 200) {
          throw Exception('Falha ao obter URL para upload da imagem.');
        }

        final Map<String, dynamic> urlData = signedUrlResponse.data;
        final String? signedUrl = urlData['signedUrl'] as String?;
        final String? avatarPath = urlData['path'] as String?;

        if (signedUrl == null || avatarPath == null) {
          throw Exception(
            'Resposta da API inválida: não foi possível obter a URL de upload.',
          );
        }

        final fileBytes = await avatarFile.readAsBytes();
        final uri = Uri.parse(signedUrl);

        final uploadResponse = await http.put(
          uri,
          body: fileBytes,
          headers: {'Content-Type': 'image/png'},
        );

        if (uploadResponse.statusCode != 200) {
          throw Exception(
            'Falha no upload da imagem para o bucket. Código: ${uploadResponse.statusCode}',
          );
        }

        finalAvatarUrl = avatarPath;

        await Supabase.instance.client
            .from('usuario')
            .update({'usr_foto_url': finalAvatarUrl})
            .eq('usr_auth_uid', newUserId);
      }

      if (context.mounted) {
        Navigator.of(
          context,
        ).pop({'password': newPassword, 'avatarUrl': finalAvatarUrl});
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Ocorreu um erro inesperado. Tente novamente.';

        if (e is FunctionException) {
          final details = e.details;
          if (details is Map && details.containsKey('error')) {
            errorMessage = details['error'];
          }
        }

        showCustomSnackbar(context, 'Erro ao criar a conta: $errorMessage', isError: true);
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateSoldier(
    BuildContext context,
    Map<String, dynamic> soldierToEdit,
  ) async {
    FocusScope.of(context).unfocus();
    hasSubmitted = true;
    notifyListeners();

    if (!(formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    _isSaving = true;
    notifyListeners();

    try {
      // final soldierId = soldierToEdit[UsuarioFields.id];
      await Future.delayed(
        const Duration(seconds: 1),
      ); 
      showCustomSnackbar(context, 'Soldado atualizado com sucesso!');
      if (context.mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (context.mounted)
        showCustomSnackbar(context, e.toString(), isError: true);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    cpfController.dispose();
    emailController.dispose();
    sectorController.dispose();
    super.dispose();
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Formato de e-mail inválido';
    return null;
  }
}
