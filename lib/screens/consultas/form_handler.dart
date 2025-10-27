import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sistema_almox/services/consulta_service.dart';
import 'package:sistema_almox/services/exam_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:sistema_almox/models/consulta_medica_model.dart';
import 'package:sistema_almox/models/exam_model.dart';

class ConsultaFormHandler with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  bool hasSubmitted = false;

  final telefoneController = TextEditingController();
  final observacoesController = TextEditingController();

  ExamModel? selectedExam;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? selectedDoctorId;
  bool _isSaving = false;

  List<ExamModel> availableExams = [];
  List<Map<String, dynamic>> availableDoctors = [];
  List<DateTime> _ocupiedTimeSlots = [];
  bool _isLoadingExams = false;
  bool _isLoadingDoctors = false;
  bool _isLoadingAvailability = false;
  Map<String, String>? _doctorWorkSchedule;

  final telefoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final ConsultaService _consultaService = ConsultaService();
  final ExamService _examService = ExamService();
  final UserService _userService = UserService.instance;

  bool _hasPhone = false;
  bool _needsPhoneInput = false;

  bool get isSaving => _isSaving;
  bool get isLoadingExams => _isLoadingExams;
  bool get isLoadingDoctors => _isLoadingDoctors;
  bool get needsPhoneInput => _needsPhoneInput;

  Future<void> loadExams() async {
    _isLoadingExams = true;
    notifyListeners();

    try {
      availableExams = await _examService.fetchActiveExams();
    } catch (e) {
      print('Erro ao carregar exames: $e');
    } finally {
      _isLoadingExams = false;
      notifyListeners();
    }
  }

  Future<void> loadDoctors() async {
    _isLoadingDoctors = true;
    notifyListeners();

    try {
      final doctors = await _userService.supabase
          .from('usuario')
          .select('id, usr_nome, usr_email')
          .eq('usr_setor_id', 4)
          .eq('usr_ativo', true);

      availableDoctors = (doctors as List).cast<Map<String, dynamic>>();

      final currentUser = _userService.currentUser;
      if (currentUser?.idSetor == 4) {
        availableDoctors.removeWhere(
          (doctor) => doctor['id'] == currentUser?.idUsuario,
        );
      }
    } catch (e) {
      print('Erro ao carregar médicos: $e');
    } finally {
      _isLoadingDoctors = false;
      notifyListeners();
    }
  }

  Future<void> checkUserPhone() async {
    try {
      final currentUser = _userService.currentUser;
      if (currentUser == null) return;

      final userData = await _userService.supabase
          .from('usuario')
          .select('usr_telefone')
          .eq('id', currentUser.idUsuario)
          .maybeSingle();

      final telefone = userData?['usr_telefone'] as String?;

      _hasPhone = telefone != null && telefone.isNotEmpty;
      _needsPhoneInput = !_hasPhone;

      if (_hasPhone && telefone != null) {
        telefoneController.text = telefoneMaskFormatter.maskText(telefone);
      }

      notifyListeners();
    } catch (e) {
      print('Erro ao verificar telefone: $e');
      _needsPhoneInput = true;
      notifyListeners();
    }
  }

  void selectExam(ExamModel? exam) {
    selectedExam = exam;
    notifyListeners();
  }

  void selectDate(DateTime date) async {
    selectedDate = date;
    selectedTime = null; // Reset time when date changes
    _ocupiedTimeSlots.clear();

    // Recarregar horário de trabalho do médico se houver
    if (selectedDoctorId != null) {
      _doctorWorkSchedule = await getDoctorWorkSchedule();
      loadAvailableSlots();
    }

    notifyListeners();
  }

  void selectTime(TimeOfDay time) {
    selectedTime = time;
    notifyListeners();
  }

  void selectDoctor(int? doctorId) async {
    selectedDoctorId = doctorId;
    _ocupiedTimeSlots.clear();
    print('Médico selecionado: $doctorId');

    // Buscar horário de trabalho do médico
    if (doctorId != null) {
      _doctorWorkSchedule = await getDoctorWorkSchedule();
      print('Horário carregado: $_doctorWorkSchedule');
    } else {
      _doctorWorkSchedule = null;
    }

    if (selectedDate != null) {
      loadAvailableSlots();
    }
    notifyListeners();
  }

  bool get isLoadingAvailability => _isLoadingAvailability;

  Future<void> loadAvailableSlots() async {
    if (selectedDoctorId == null || selectedDate == null) return;

    _isLoadingAvailability = true;
    notifyListeners();

    try {
      // Buscar consultas ocupadas
      final response = await _userService.supabase
          .from('consulta_medica')
          .select('con_data_agendamento')
          .eq('con_medico_responsavel_id', selectedDoctorId!)
          .eq('con_status', 'agendada')
          .gte(
            'con_data_agendamento',
            '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}T00:00:00.000Z',
          )
          .lt(
            'con_data_agendamento',
            '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}T23:59:59.999Z',
          );

      _ocupiedTimeSlots = (response as List)
          .map((item) => DateTime.parse(item['con_data_agendamento'] as String))
          .toList();
    } catch (e) {
      print('Erro ao carregar horários ocupados: $e');
    } finally {
      _isLoadingAvailability = false;
      notifyListeners();
    }
  }

  Future<Map<String, String>?> getDoctorWorkSchedule() async {
    if (selectedDoctorId == null) return null;

    try {
      final response = await _userService.supabase
          .from('usuario')
          .select('usr_horario_inicio, usr_horario_fim')
          .eq('id', selectedDoctorId!)
          .maybeSingle();

      if (response == null) return null;

      return {
        'horarioInicio': response['usr_horario_inicio'] as String? ?? '08:00',
        'horarioFim': response['usr_horario_fim'] as String? ?? '17:00',
      };
    } catch (e) {
      print('Erro ao buscar horário de trabalho: $e');
      return null;
    }
  }

  List<TimeOfDay> getAvailableTimeSlots() {
    print('getAvailableTimeSlots chamado');
    print('selectedDate: $selectedDate');
    print('_doctorWorkSchedule: $_doctorWorkSchedule');
    if (selectedDate == null) {
      print('Sem data selecionada');
      return [];
    }

    final now = DateTime.now();
    final isToday =
        selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day;

    final availableSlots = <TimeOfDay>[];

    // Buscar horário de trabalho do médico
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);

    if (_doctorWorkSchedule != null) {
      // Parse do horário de início
      final inicioStr = (_doctorWorkSchedule!['horarioInicio'] ?? '08:00')
          .toString();
      final inicioParts = inicioStr.split(':');

      // Converter para 24h se necessário
      int horaInicio = int.tryParse(inicioParts[0]) ?? 8;
      if (horaInicio < 8 &&
          !inicioStr.toUpperCase().contains('AM') &&
          !inicioStr.toUpperCase().contains('PM')) {
        // Se a hora for menor que 8, provavelmente é PM (ex: 3:25 = 15:25)
        horaInicio = horaInicio + 12;
      }

      int minutoInicio = int.tryParse(inicioParts[1]) ?? 0;

      startTime = TimeOfDay(hour: horaInicio, minute: minutoInicio);

      // Parse do horário de fim
      final fimStr = (_doctorWorkSchedule!['horarioFim'] ?? '17:00').toString();
      final fimParts = fimStr.split(':');

      int horaFim = int.tryParse(fimParts[0]) ?? 17;
      // Se for formato 3:25 (sem AM/PM), assume PM
      if (horaFim < 8 &&
          !fimStr.toUpperCase().contains('AM') &&
          !fimStr.toUpperCase().contains('PM')) {
        horaFim = horaFim + 12;
      }

      int minutoFim = int.tryParse(fimParts[1]) ?? 0;

      endTime = TimeOfDay(hour: horaFim, minute: minutoFim);

      print(
        'Horário parseado - Início: $horaInicio:${minutoInicio.toString().padLeft(2, '0')}, Fim: $horaFim:${minutoFim.toString().padLeft(2, '0')}',
      );
    } else {
      print('Não há horário de trabalho configurado para este médico');
    }

    // Se for hoje, só mostrar horários futuros
    if (isToday) {
      final nextTime = TimeOfDay(
        hour: now.hour,
        minute: ((now.minute ~/ 30) + 1) * 30,
      );
      if (nextTime.hour > startTime.hour ||
          (nextTime.hour == startTime.hour &&
              nextTime.minute > startTime.minute)) {
        startTime = nextTime;
      }
    }

    // Gerar slots apenas dentro do horário de trabalho
    // Converter para minutos totais para facilitar comparação
    int startTotalMinutes = startTime.hour * 60 + startTime.minute;
    int endTotalMinutes = endTime.hour * 60 + endTime.minute;

    // Arredondar o início para o próximo slot de 30 minutos
    // Se já está em múltiplo de 30, pega o próximo
    // Ex: 07:25 vira 07:30, 08:00 vira 08:00
    int currentTotalMinutes = startTotalMinutes;
    if (currentTotalMinutes % 30 != 0) {
      currentTotalMinutes = ((currentTotalMinutes ~/ 30) + 1) * 30;
    }

    print(
      'Horário de trabalho: ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} até ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
    );
    print(
      'Início arredondado: ${currentTotalMinutes ~/ 60}:${(currentTotalMinutes % 60).toString().padLeft(2, '0')}',
    );

    while (currentTotalMinutes < endTotalMinutes) {
      int hour = currentTotalMinutes ~/ 60;
      int minute = currentTotalMinutes % 60;
      final currentTime = TimeOfDay(hour: hour, minute: minute);

      final timeSlot = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        hour,
        minute,
      );

      final isOccupied = _ocupiedTimeSlots.any((occupiedTime) {
        return occupiedTime.year == timeSlot.year &&
            occupiedTime.month == timeSlot.month &&
            occupiedTime.day == timeSlot.day &&
            occupiedTime.hour == timeSlot.hour &&
            occupiedTime.minute == timeSlot.minute;
      });

      if (!isOccupied) {
        availableSlots.add(currentTime);
      }

      // Próximo slot (30 minutos depois)
      currentTotalMinutes += 30;
    }

    print('Total de slots disponíveis gerados: ${availableSlots.length}');
    if (availableSlots.isNotEmpty) {
      print(
        'Primeiro slot: ${availableSlots.first.hour}:${availableSlots.first.minute.toString().padLeft(2, '0')}',
      );
      print(
        'Último slot: ${availableSlots.last.hour}:${availableSlots.last.minute.toString().padLeft(2, '0')}',
      );
    }

    return availableSlots;
  }

  bool isTimeSlotAvailable(TimeOfDay time) {
    if (selectedDate == null) return false;

    final timeSlot = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      time.hour,
      time.minute,
    );

    return !_ocupiedTimeSlots.any((occupiedTime) {
      return occupiedTime.year == timeSlot.year &&
          occupiedTime.month == timeSlot.month &&
          occupiedTime.day == timeSlot.day &&
          occupiedTime.hour == timeSlot.hour &&
          occupiedTime.minute == timeSlot.minute;
    });
  }

  Future<void> submitAppointment(BuildContext context) async {
    FocusScope.of(context).unfocus();
    hasSubmitted = true;
    notifyListeners();

    if (!(formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    if (selectedExam == null ||
        selectedDate == null ||
        selectedTime == null ||
        selectedDoctorId == null) {
      showCustomSnackbar(
        context,
        'Por favor, preencha todos os campos.',
        isError: true,
      );
      return;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final currentUser = _userService.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      if (currentUser.idSetor == 4 &&
          currentUser.idUsuario == selectedDoctorId) {
        throw Exception('Médicos não podem marcar consultas para si mesmos');
      }

      // Só salva telefone se for necessário (usuário preencheu ou não tinha)
      if (_needsPhoneInput ||
          (!_hasPhone && telefoneController.text.isNotEmpty)) {
        final unmaskedTelefone = telefoneMaskFormatter.getUnmaskedText();
        if (unmaskedTelefone.isNotEmpty && unmaskedTelefone.length >= 10) {
          await _userService.supabase
              .from('usuario')
              .update({'usr_telefone': unmaskedTelefone})
              .eq('usr_auth_uid', currentUser.authUid);
        }
      }

      final appointmentDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final appointment = ConsultaMedicaModel(
        id: 0,
        pacienteId: currentUser.idUsuario,
        exameId: selectedExam!.id,
        dataAgendamento: appointmentDateTime,
        status: StatusConsulta.agendada,
        observacoes: observacoesController.text.trim(),
        medicoResponsavelId: selectedDoctorId,
      );

      await _consultaService.createAppointment(appointment);

      if (context.mounted) {
        showCustomSnackbar(context, 'Consulta agendada com sucesso!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackbar(
          context,
          'Erro ao agendar: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String? validateTelefone(String? value) {
    // Só valida se o usuário precisa preencher
    if (!_needsPhoneInput) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Telefone é obrigatório';
    }
    final unmasked = telefoneMaskFormatter.getUnmaskedText();
    if (unmasked.length < 10) {
      return 'Telefone inválido';
    }
    return null;
  }

  @override
  void dispose() {
    telefoneController.dispose();
    observacoesController.dispose();
    super.dispose();
  }
}
