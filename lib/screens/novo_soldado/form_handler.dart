import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterSoldierFormHandler with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  bool hasSubmitted = false;
  bool houveTrocaDeCargo = false;

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
  bool _isInitialImageLoading = false;
  bool _userPickedNewImage = false;
  XFile? get selectedImage => _selectedImage;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  final _userService = UserService.instance;

  bool get isInitialImageLoading => _isInitialImageLoading;

  void init(Map<String, dynamic>? soldierToEdit) {
    _selectedImage = null;
    _userPickedNewImage = false;
    houveTrocaDeCargo = false;

    notifyListeners();

    if (soldierToEdit != null) {
      nameController.text = soldierToEdit[UsuarioFields.nome] ?? '';
      final rawCpf = soldierToEdit[UsuarioFields.cpf] ?? '';
      cpfController.text = cpfMaskFormatter.maskText(rawCpf);
      emailController.text = soldierToEdit[UsuarioFields.email] ?? '';

      final String? photoUrl = soldierToEdit[UsuarioFields.fotoUrl];
      if (photoUrl != null && photoUrl.isNotEmpty) {
        _loadInitialImageFromUrl(photoUrl);
      }
    }
  }

  Future<void> _loadInitialImageFromUrl(String photoUrl) async {
    _isInitialImageLoading = true;
    notifyListeners();

    try {
      final tempDir = await getTemporaryDirectory();
      final String uniqueFileName = photoUrl.replaceAll('/', '_');
      final file = File('${tempDir.path}/$uniqueFileName');

      if (await file.exists()) {
        await file.delete();
      }

      final signedUrl = await UserService.instance.createSignedUrlForAvatar(
        photoUrl,
      );
      if (signedUrl.isEmpty) {
        _selectedImage = null;
        return;
      }

      final response = await http.get(Uri.parse(signedUrl));
      if (response.statusCode != 200) return;

      await file.writeAsBytes(response.bodyBytes);

      _selectedImage = XFile(file.path);
    } catch (e) {
      _selectedImage = null;
    } finally {
      _isInitialImageLoading = false;
      notifyListeners();
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
    _userPickedNewImage = true;
    notifyListeners();
  }

  void clearImage() {
    if (_selectedImage != null) {
      _selectedImage = null;
      _userPickedNewImage = true;
      notifyListeners();
    }
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

        showCustomSnackbar(
          context,
          'Erro ao criar a conta: $errorMessage',
          isError: true,
        );
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
      final String userId = soldierToEdit[UsuarioFields.authUid];
      String? finalAvatarUrl = soldierToEdit[UsuarioFields.fotoUrl];
      String? newAvatarPath;

      final bool imageHasChanged = _userPickedNewImage;

      if (imageHasChanged) {
        if (_selectedImage != null) {
          final signedUrlResponse = await Supabase.instance.client.functions
              .invoke('create-signed-avatar-url', body: {'userId': userId});

          if (signedUrlResponse.status != 200) {
            throw Exception('Falha ao obter URL para upload da nova imagem.');
          }

          final urlData = signedUrlResponse.data;
          final String? signedUrl = urlData['signedUrl'] as String?;
          final String? avatarPath = urlData['path'] as String?;

          if (signedUrl == null || avatarPath == null) {
            throw Exception('Resposta da API inválida para URL de upload.');
          }

          final fileBytes = await _selectedImage!.readAsBytes();
          final uri = Uri.parse(signedUrl);

          final uploadResponse = await http.put(
            uri,
            body: fileBytes,
            headers: {'Content-Type': 'image/png'},
          );

          if (uploadResponse.statusCode != 200) {
            throw Exception(
              'Falha no upload da nova imagem. Código: ${uploadResponse.statusCode}',
            );
          }

          newAvatarPath = avatarPath;
          finalAvatarUrl = newAvatarPath;
        } else {
          finalAvatarUrl = null;
        }
      }

      final unmaskedCpf = cpfController.text.replaceAll(RegExp(r'[^\d]'), '');

      final Map<String, dynamic> metadata = {
        'display_name': nameController.text.trim(),
        'foto_url': finalAvatarUrl,
      };

      if (unmaskedCpf.isNotEmpty) {
        metadata['cpf'] = unmaskedCpf;
      }

      final updateData = {
        'userId': userId,
        'email': emailController.text.trim(),
        'metadata': metadata,
        'atualizar_data_cargo': houveTrocaDeCargo,
      };

      final response = await Supabase.instance.client.functions.invoke(
        'update-user',
        body: updateData,
      );

      if (response.status != 200) {
        throw FunctionException(
          status: response.status,
          details: response.data?['error'] ?? 'Falha ao atualizar o usuário.',
        );
      }

      if (context.mounted) {
        showCustomSnackbar(context, 'Usuário atualizado com sucesso!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Ocorreu um erro inesperado. Tente novamente.';
        if (e.toString().toLowerCase().contains('cpf') ||
            e.toString().contains('usr_cpf_key')) {
          errorMessage = 'O CPF informado já está em uso por outro usuário.';
        } else if (e.toString().toLowerCase().contains('email') ||
            e.toString().contains('usr_email_key')) {
          errorMessage = 'O E-mail informado já está cadastrado.';
        } else if (e is FunctionException) {
          errorMessage = e.details.toString();
        } else {
          errorMessage = e.toString();
        }
        showCustomSnackbar(
          context,
          'Erro ao atualizar: $errorMessage',
          isError: true,
        );
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deactivateUser(
    BuildContext context,
    Map<String, dynamic> soldierToEdit,
  ) async {
    _isSaving = true;
    notifyListeners();

    try {
      final String userIdToDeactivate = soldierToEdit[UsuarioFields.authUid];

      await Supabase.instance.client
          .from('usuario')
          .update({'usr_ativo': false})
          .eq('usr_auth_uid', userIdToDeactivate);

      if (context.mounted) {
        showCustomSnackbar(context, 'Usuário desativado com sucesso!');
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (context.mounted) {
        showCustomSnackbar(
          context,
          'Erro ao desativar: ${error.toString()}',
          isError: true,
        );
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> reactivateUser(
    BuildContext context,
    Map<String, dynamic> soldierToEdit,
  ) async {
    _isSaving = true;
    notifyListeners();

    try {
      final String userIdToReactivate = soldierToEdit[UsuarioFields.authUid];

      await Supabase.instance.client
          .from('usuario')
          .update({'usr_ativo': true})
          .eq('usr_auth_uid', userIdToReactivate);

      if (context.mounted) {
        showCustomSnackbar(context, 'Usuário reativado com sucesso!');
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (context.mounted) {
        showCustomSnackbar(
          context,
          'Erro ao reativar: ${error.toString()}',
          isError: true,
        );
      }
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
