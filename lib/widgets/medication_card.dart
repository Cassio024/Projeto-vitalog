// ARQUIVO CORRIGIDO: lib/widgets/medication_card.dart

import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../utils/app_colors.dart';

// Definimos os possíveis valores para as ações do menu para um código mais limpo
enum MedicationAction { edit, delete }

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onEdit;   // ADICIONADO: Função a ser chamada para editar
  final VoidCallback onDelete; // Função a ser chamada para apagar

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onEdit,   // ADICIONADO
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // REMOVIDO: Toda a lógica de 'Provider' e 'services' foi retirada daqui.
    // O card não precisa saber como apagar ou editar, ele apenas avisa que o botão foi clicado.

    return Card(
      elevation: 4,
      shadowColor: AppColors.lightGrey.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.medication_liquid, color: AppColors.primary, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dosagem: ${medication.dosage}',
                    style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Expanded( // Garante que o texto não vai quebrar a linha
                        child: Text(
                          'Horários: ${medication.schedules.join(", ")}',
                          style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // LÓGICA DO MENU CORRIGIDA E SIMPLIFICADA
            PopupMenuButton<MedicationAction>(
              onSelected: (MedicationAction action) {
                // Apenas chama a função correspondente que foi passada pela HomeScreen
                if (action == MedicationAction.edit) {
                  onEdit();
                } else if (action == MedicationAction.delete) {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: MedicationAction.edit,
                  child: Text('Editar'),
                ),
                const PopupMenuItem(
                  value: MedicationAction.delete,
                  child: Text('Apagar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}