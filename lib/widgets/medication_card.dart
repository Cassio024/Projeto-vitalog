// Arquivo: lib/widgets/medication_card.dart
// MODIFICADO: Recebe uma função para deletar.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication_model.dart';
import '../screens/add_edit_medication_screen.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onDelete; // Função que será chamada ao deletar

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.medication_liquid, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medication.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Dosagem: ${medication.dosage}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text('Horários: ${medication.schedules.join(", ")}'),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  // A lógica de edição precisa passar o ID e recarregar a lista na volta
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddEditMedicationScreen(medication: medication)),
                  );
                } else if (value == 'delete') {
                  // Mostra um diálogo de confirmação antes de deletar
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirmar Exclusão'),
                      content: Text('Tem certeza que deseja remover "${medication.name}"?'),
                      actions: [
                        TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop()),
                        TextButton(
                          child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            onDelete(); // Chama a função de deletar
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}