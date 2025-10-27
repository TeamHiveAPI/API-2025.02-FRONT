import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/models/exam_model.dart';
import 'package:sistema_almox/screens/consultas/form_handler.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';

class AgendarConsultaScreen extends StatefulWidget {
  const AgendarConsultaScreen({super.key});

  @override
  State<AgendarConsultaScreen> createState() => _AgendarConsultaScreenState();
}

class _AgendarConsultaScreenState extends State<AgendarConsultaScreen> {
  final _formHandler = ConsultaFormHandler();

  @override
  void initState() {
    super.initState();
    _formHandler.addListener(() => setState(() {}));
    _formHandler.loadExams();
    _formHandler.loadDoctors();
    _formHandler.checkUserPhone();
  }

  @override
  void dispose() {
    _formHandler.removeListener(() {});
    _formHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            InternalPageHeader(title: 'Agendar Consulta'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formHandler.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Só mostra campo de telefone se o usuário não tiver telefone
                      if (_formHandler.needsPhoneInput)
                        TextFormField(
                          controller: _formHandler.telefoneController,
                          decoration: InputDecoration(
                            labelText: 'TELEFONE',
                            hintText: '(00) 00000-0000',
                          ),
                          inputFormatters: [_formHandler.telefoneMaskFormatter],
                          validator: _formHandler.validateTelefone,
                        ),
                      if (_formHandler.needsPhoneInput)
                        const SizedBox(height: 24),
                      DropdownButton<ExamModel>(
                        value: _formHandler.selectedExam,
                        hint: const Text('SELECIONE O EXAME'),
                        items: _formHandler.availableExams
                            .map(
                              (exam) => DropdownMenuItem(
                                value: exam,
                                child: Text(exam.nome),
                              ),
                            )
                            .toList(),
                        onChanged: _formHandler.selectExam,
                      ),
                      const SizedBox(height: 24),
                      DropdownButton<int>(
                        value: _formHandler.selectedDoctorId,
                        hint: const Text('SELECIONE O MÉDICO'),
                        items: _formHandler.availableDoctors
                            .map(
                              (d) => DropdownMenuItem(
                                value: d['id'] as int,
                                child: Text(d['usr_nome'] as String),
                              ),
                            )
                            .toList(),
                        onChanged: _formHandler.selectDoctor,
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                          );
                          if (date != null) _formHandler.selectDate(date);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formHandler.selectedDate != null
                                    ? DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_formHandler.selectedDate!)
                                    : 'DATA',
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Mostrar horários disponíveis
                      if (_formHandler.selectedDoctorId != null &&
                          _formHandler.selectedDate != null) ...[
                        const Text(
                          'SELECIONE O HORÁRIO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: text60,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_formHandler.isLoadingAvailability)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          _buildTimeSlotsGrid(),
                        const SizedBox(height: 24),
                      ] else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Selecione o médico e a data primeiro',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const Icon(Icons.access_time, color: Colors.grey),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _formHandler.observacoesController,
                        decoration: const InputDecoration(
                          labelText: 'OBSERVAÇÕES (OPCIONAL)',
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _formHandler.isSaving
                            ? null
                            : () => _formHandler.submitAppointment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _formHandler.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Confirmar Agendamento'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsGrid() {
    final availableSlots = _formHandler.getAvailableTimeSlots();

    if (availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Não há horários disponíveis nesta data.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableSlots.map((time) {
        final isSelected =
            _formHandler.selectedTime != null &&
            _formHandler.selectedTime!.hour == time.hour &&
            _formHandler.selectedTime!.minute == time.minute;

        return InkWell(
          onTap: () => _formHandler.selectTime(time),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? brandBlue : Colors.white,
              border: Border.all(
                color: isSelected ? brandBlue : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time.format(context),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
