// Arquivo: lib/widgets/medication_card.dart
import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../utils/app_colors.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewOrGenerateQrCode;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onEdit,
    required this.onDelete,
    required this.onViewOrGenerateQrCode,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpired = medication.isExpired;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isExpired ? Colors.red.shade700 : Colors.transparent,
          width: 1.5,
        ),
      ),
      color: isExpired ? Colors.red.shade50 : Colors.white,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication_liquid, color: isExpired ? Colors.red.shade700 : AppColors.primary, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isExpired ? Colors.red.shade900 : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dosagem: ${medication.dosage}',
                        style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    } else if (value == 'qr_code') {
                      onViewOrGenerateQrCode();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(value: 'delete', child: Text('Apagar')),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'qr_code',
                      child: Row(
                        children: [
                          Icon(Icons.qr_code_2, color: AppColors.textLight),
                          SizedBox(width: 8),
                          Text('Gerar QR Code'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.textLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Horários: ${medication.schedules.join(", ")}',
                    style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isExpired)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'MEDICAMENTO VENCIDO!',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
