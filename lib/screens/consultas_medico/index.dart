import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/models/consulta_medica_model.dart';
import 'package:sistema_almox/services/consulta_medico_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class ConsultasMedicoScreen extends StatefulWidget {
  const ConsultasMedicoScreen({super.key});

  @override
  State<ConsultasMedicoScreen> createState() => _ConsultasMedicoScreenState();
}

class _ConsultasMedicoScreenState extends State<ConsultasMedicoScreen> {
  final ConsultaMedicoService _service = ConsultaMedicoService();
  final UserService _userService = UserService.instance;

  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _pendingAppointments = [];
  List<Map<String, dynamic>> _completedAppointments = [];
  bool _isLoading = true;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _categorizeAppointments() {
    _pendingAppointments = [];
    _completedAppointments = [];

    for (var apt in _appointments) {
      final status = apt[ConsultaMedicaFields.status] as String?;
      if (status == 'realizada' || status == 'cancelada') {
        _completedAppointments.add(apt);
      } else {
        _pendingAppointments.add(apt);
      }
    }
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = _userService.currentUser;
      if (currentUser == null) return;

      _appointments = await _service.fetchDoctorAppointments(
        currentUser.idUsuario,
      );
      _categorizeAppointments();
    } catch (e) {
      print('Erro ao carregar consultas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAppointmentStatus(
    int appointmentId,
    StatusConsulta newStatus,
  ) async {
    try {
      await _service.updateAppointmentStatus(appointmentId, newStatus);
      if (mounted) {
        showCustomSnackbar(
          context,
          newStatus == StatusConsulta.realizada
              ? 'Consulta marcada como realizada'
              : newStatus == StatusConsulta.cancelada
              ? 'Consulta cancelada'
              : 'Status atualizado',
        );
      }
      _loadAppointments();
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          'Erro ao atualizar status: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'agendada':
        return Colors.blue;
      case 'realizada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'reagendada':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Center(
                child: Text(
                  'Minhas Consultas - Médico',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: brandBlue,
                  ),
                ),
              ),
            ),
            // Filtros
            if (!_isLoading && _appointments.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text(
                          'Pendentes (${_pendingAppointments.length})',
                        ),
                        selected: !_showCompleted,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _showCompleted = false);
                          }
                        },
                        selectedColor: brandBlue,
                        labelStyle: TextStyle(
                          color: !_showCompleted
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: !_showCompleted
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: Text(
                          'Concluídas (${_completedAppointments.length})',
                        ),
                        selected: _showCompleted,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _showCompleted = true);
                          }
                        },
                        selectedColor: brandBlue,
                        labelStyle: TextStyle(
                          color: _showCompleted ? Colors.white : Colors.black87,
                          fontWeight: _showCompleted
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_showCompleted
                            ? _completedAppointments
                            : _pendingAppointments)
                        .isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showCompleted
                                ? 'Nenhuma consulta concluída'
                                : 'Nenhuma consulta pendente',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: text80,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount:
                          (_showCompleted
                                  ? _completedAppointments
                                  : _pendingAppointments)
                              .length,
                      itemBuilder: (context, index) {
                        final apt = (_showCompleted
                            ? _completedAppointments
                            : _pendingAppointments)[index];
                        final data =
                            apt[ConsultaMedicaFields.dataAgendamento] != null
                            ? DateTime.parse(
                                apt[ConsultaMedicaFields.dataAgendamento]
                                    as String,
                              )
                            : null;
                        final exame = apt['exame'] as Map?;
                        final paciente = apt['paciente'] as Map?;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          apt[ConsultaMedicaFields.status]
                                              as String,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        apt[ConsultaMedicaFields.status]
                                                ?.toString()
                                                .toUpperCase() ??
                                            'AGENDADA',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(
                                            apt[ConsultaMedicaFields.status]
                                                as String,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (data != null)
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(data),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (paciente != null)
                                  Text(
                                    'Paciente: ${paciente[UsuarioFields.nome]}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (exame != null) ...[
                                  const SizedBox(height: 8),
                                  Text('Exame: ${exame[ExameFields.nome]}'),
                                ],
                                if (data != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: text60,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(DateFormat('HH:mm').format(data)),
                                    ],
                                  ),
                                ],
                                if (paciente != null &&
                                    paciente[UsuarioFields.telefone] !=
                                        null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        size: 16,
                                        color: text60,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${paciente[UsuarioFields.telefone]}',
                                      ),
                                    ],
                                  ),
                                ],
                                // Botões de ação apenas para consultas pendentes
                                if (!_showCompleted &&
                                    apt[ConsultaMedicaFields.status] !=
                                        'realizada' &&
                                    apt[ConsultaMedicaFields.status] !=
                                        'cancelada') ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _updateAppointmentStatus(
                                              apt[ConsultaMedicaFields.id]
                                                  as int,
                                              StatusConsulta.realizada,
                                            ),
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text('Concluir'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _updateAppointmentStatus(
                                              apt[ConsultaMedicaFields.id]
                                                  as int,
                                              StatusConsulta.cancelada,
                                            ),
                                        icon: const Icon(
                                          Icons.cancel,
                                          size: 18,
                                        ),
                                        label: const Text('Cancelar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
