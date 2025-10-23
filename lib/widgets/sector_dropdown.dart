import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/user_service.dart';

class SectorDropdown extends StatelessWidget {
  final int? selectedSectorId;
  final Function(int) onSectorChanged;
  final bool enabled;

  const SectorDropdown({
    super.key,
    required this.selectedSectorId,
    required this.onSectorChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final userService = UserService.instance;
    final currentUser = userService.currentUser;

    // Lista de setores disponíveis
    final List<Map<String, dynamic>> availableSectors = [
      {'id': 1, 'name': 'Almoxarifado'},
      {'id': 2, 'name': 'Farmácia'},
      {'id': 3, 'name': 'Odontologia'},
      {'id': 4, 'name': 'Médico'},
      {'id': 5, 'name': 'Comum'},
    ];

    // Se não for coronel, filtrar apenas o setor atual
    List<Map<String, dynamic>> sectorsToShow = availableSectors;
    if (currentUser?.nivelAcesso != 3) {
      sectorsToShow = availableSectors
          .where((sector) => sector['id'] == currentUser?.idSetor)
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SETOR',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: text60,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<int>(
            initialValue: selectedSectorId,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
            hint: const Text('Selecione o setor'),
            isExpanded: true,
            items: sectorsToShow.map((sector) {
              return DropdownMenuItem<int>(
                value: sector['id'],
                child: Text(sector['name']),
              );
            }).toList(),
            onChanged: enabled
                ? (value) {
                    if (value != null) {
                      onSectorChanged(value);
                    }
                  }
                : null,
            validator: (value) {
              if (value == null) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
