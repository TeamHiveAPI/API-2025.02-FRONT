import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/consulta_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'agendar_consulta/index.dart';

class ConsultasScreen extends StatefulWidget {
  const ConsultasScreen({super.key});

  @override
  State<ConsultasScreen> createState() => _ConsultasScreenState();
}

class _ConsultasScreenState extends State<ConsultasScreen> {
  final ConsultaService _consultaService = ConsultaService();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = UserService.instance.currentUser;
      if (currentUser == null) return;

      _appointments = await _consultaService.fetchAppointmentsWithDetails(
        patientId: currentUser.idUsuario,
      );
    } catch (e) {
      print('Erro ao carregar consultas: $e');
    } finally {
      setState(() => _isLoading = false);
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
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  'Minhas Consultas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: brandBlue,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _appointments.isEmpty
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
                            'Nenhuma consulta agendada',
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
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final apt = _appointments[index];
                        final data =
                            apt[ConsultaMedicaFields.dataAgendamento] != null
                            ? DateTime.parse(
                                apt[ConsultaMedicaFields.dataAgendamento]
                                    as String,
                              )
                            : null;
                        final exame = apt['exame'] as Map?;
                        final medico = apt['medico'] as Map?;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: brightGray,
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
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        apt[ConsultaMedicaFields.status]
                                                ?.toString()
                                                .toUpperCase() ??
                                            'AGENDADA',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
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
                                if (exame != null)
                                  Text(
                                    exame[ExameFields.nome] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (medico != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: text60,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Dr. ${medico[UsuarioFields.nome]}'),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 60, bottom: 3.0),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgendarConsultaScreen()),
          ).then((_) => _loadAppointments()),
          backgroundColor: brandBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Agendar Consulta',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
