// Arquivo: lib/widgets/medication_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication_model.dart';

/// Um pop-up que exibe os detalhes de um medicamento.
class MedicationDetailsDialog extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsDialog({
    super.key,
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpired = medication.isExpired;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isExpired ? Colors.red.shade700 : Colors.transparent,
          width: 2,
        ),
      ),
      title: const Text('Detalhes do Medicamento'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            // PopUp de aviso de medicamento vencido.
            if (isExpired)
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ATENÇÃO: MEDICAMENTO VENCIDO!',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            _buildDetailRow(Icons.medication, 'Nome', medication.name),
            _buildDetailRow(Icons.scale, 'Dosagem', medication.dosage),
            _buildDetailRow(Icons.access_time, 'Horários', medication.schedules.join(', ')),
            if (medication.expirationDate != null)
              _buildDetailRow(
                Icons.event_busy,
                'Validade',
                DateFormat('dd/MM/yyyy').format(medication.expirationDate!),
                isExpired: isExpired,
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Fechar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  /// Helper para construir uma linha de detalhe formatada.
  Widget _buildDetailRow(IconData icon, String label, String value, {bool isExpired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isExpired ? Colors.red : Colors.teal, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 16, color: isExpired ? Colors.red.shade800 : Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
