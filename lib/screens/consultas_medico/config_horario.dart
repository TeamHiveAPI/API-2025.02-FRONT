import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/consulta_medico_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class ConfigHorarioScreen extends StatefulWidget {
  const ConfigHorarioScreen({super.key});

  @override
  State<ConfigHorarioScreen> createState() => _ConfigHorarioScreenState();
}

class _ConfigHorarioScreenState extends State<ConfigHorarioScreen> {
  final ConsultaMedicoService _service = ConsultaMedicoService();
  final UserService _userService = UserService.instance;

  final _horarioInicioController = TextEditingController();
  final _horarioFimController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadWorkSchedule();
  }

  @override
  void dispose() {
    _horarioInicioController.dispose();
    _horarioFimController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTimeFromString(String timeStr) {
    try {
      // Parse "HH:MM AM/PM" para TimeOfDay
      final parts = timeStr.split(' ');
      final timePart = parts[0];
      final isPM = parts.length > 1 && parts[1].toUpperCase().contains('PM');

      final hourMinutes = timePart.split(':');
      int hour = int.parse(hourMinutes[0]);
      int minute = int.parse(hourMinutes[1]);

      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      // Se der erro, retorna hora atual
      return TimeOfDay.now();
    }
  }

  TimeOfDay _roundToNearestHalfHour(TimeOfDay time) {
    // Arredondar para o próximo múltiplo de 30 minutos
    int minute = time.minute;
    if (minute % 30 != 0) {
      minute = ((minute ~/ 30) + 1) * 30;
      if (minute >= 60) {
        minute = 0;
        time = TimeOfDay(hour: time.hour + 1, minute: 0);
      }
    }
    return TimeOfDay(hour: time.hour, minute: minute);
  }

  Future<void> _loadWorkSchedule() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = _userService.currentUser;
      if (currentUser == null) return;

      final schedule = await _service.getWorkSchedule(currentUser.idUsuario);

      if (schedule != null) {
        // Carregar horários salvos
        _horarioInicioController.text = schedule['horarioInicio'] ?? '08:00';
        _horarioFimController.text = schedule['horarioFim'] ?? '17:00';
      } else {
        // Valores padrão
        _horarioInicioController.text = '08:00';
        _horarioFimController.text = '17:00';
      }
    } catch (e) {
      print('Erro ao carregar horário: $e');
      _horarioInicioController.text = '08:00';
      _horarioFimController.text = '17:00';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _convertTimeOfDayToHHMM(String timeFormatted) {
    // timeFormatted vem como "HH:MM AM/PM" ou "HH:MM"
    try {
      final parts = timeFormatted.split(' ');
      final timeStr = parts[0]; // Pega "HH:MM"
      return timeStr;
    } catch (e) {
      return timeFormatted;
    }
  }

  Future<void> _saveWorkSchedule() async {
    setState(() => _isSaving = true);
    try {
      final currentUser = _userService.currentUser;
      if (currentUser == null) return;

      // Converter formato do time picker para HH:MM
      final horarioInicio = _convertTimeOfDayToHHMM(
        _horarioInicioController.text,
      );
      final horarioFim = _convertTimeOfDayToHHMM(_horarioFimController.text);

      await _service.updateWorkSchedule(
        medicoId: currentUser.idUsuario,
        horarioInicio: horarioInicio,
        horarioFim: horarioFim,
      );

      if (mounted) {
        showCustomSnackbar(
          context,
          'Horário de trabalho atualizado com sucesso!',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          'Erro ao salvar: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            InternalPageHeader(title: 'Configurar Horário de Trabalho'),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Defina seus horários de trabalho para que os pacientes possam agendar consultas no seu expediente.',
                            style: TextStyle(fontSize: 14, color: text60),
                          ),
                          const SizedBox(height: 32),

                          InkWell(
                            onTap: () async {
                              final initialTime =
                                  _horarioInicioController.text.isEmpty
                                  ? TimeOfDay.now()
                                  : _parseTimeFromString(
                                      _horarioInicioController.text,
                                    );

                              final time = await showTimePicker(
                                context: context,
                                initialTime: initialTime,
                              );

                              if (time != null && mounted) {
                                // Arredondar para o próximo múltiplo de 30 minutos
                                final roundedTime = _roundToNearestHalfHour(
                                  time,
                                );

                                setState(() {
                                  _horarioInicioController.text = roundedTime
                                      .format(context);
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _horarioInicioController.text.isEmpty
                                        ? 'HORÁRIO DE INÍCIO'
                                        : _horarioInicioController.text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          _horarioInicioController.text.isEmpty
                                          ? Colors.grey
                                          : Colors.black87,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.access_time,
                                    color: brandBlue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          InkWell(
                            onTap: () async {
                              final initialTime =
                                  _horarioFimController.text.isEmpty
                                  ? TimeOfDay.now()
                                  : _parseTimeFromString(
                                      _horarioFimController.text,
                                    );

                              final time = await showTimePicker(
                                context: context,
                                initialTime: initialTime,
                              );

                              if (time != null && mounted) {
                                // Arredondar para o próximo múltiplo de 30 minutos
                                final roundedTime = _roundToNearestHalfHour(
                                  time,
                                );

                                setState(() {
                                  _horarioFimController.text = roundedTime
                                      .format(context);
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _horarioFimController.text.isEmpty
                                        ? 'HORÁRIO DE FIM'
                                        : _horarioFimController.text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _horarioFimController.text.isEmpty
                                          ? Colors.grey
                                          : Colors.black87,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.access_time,
                                    color: brandBlue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveWorkSchedule,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              _isSaving ? 'Salvando...' : 'Salvar Horário',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
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
}
