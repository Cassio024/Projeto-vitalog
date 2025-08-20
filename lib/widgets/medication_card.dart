// Arquivo: lib/widgets/medication_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication_model.dart';
import '../utils/app_colors.dart';

// Classe auxiliar para guardar o status de cada dose
class DoseStatus {
  final String scheduleTime; // "HH:mm"
  final String doseKey; // "yyyy-MM-dd HH:mm"
  final bool isTaken;
  final bool isMissed;
  final bool isUpcoming;

  DoseStatus({
    required this.scheduleTime,
    required this.doseKey,
    required this.isTaken,
    required this.isMissed,
    required this.isUpcoming,
  });
}

class MedicationCard extends StatefulWidget {
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewOrGenerateQrCode;
  // NOVO PARÂMETRO: Função para confirmar a dose
  final Function(String doseKey) onConfirmDose;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onEdit,
    required this.onDelete,
    required this.onViewOrGenerateQrCode,
    // NOVO PARÂMETRO
    required this.onConfirmDose,
  });

  @override
  State<MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard> {
  bool _hasMissedDose = false;
  List<DoseStatus> _doseStatusList = [];

  @override
  void initState() {
    super.initState();
    _prepareDoseStatus();
  }

  // Garante que o card atualize se os dados do medicamento mudarem
  @override
  void didUpdateWidget(covariant MedicationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.medication != oldWidget.medication) {
      _prepareDoseStatus();
    }
  }

  // A lógica principal para verificar cada dose do dia
  void _prepareDoseStatus() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final medication = widget.medication;
    bool missedDoseFound = false;
    List<DoseStatus> statusList = [];

    if (medication.schedules.isEmpty) {
      setState(() {
        _hasMissedDose = false;
        _doseStatusList = [];
      });
      return;
    }

    for (String schedule in medication.schedules) {
      final parts = schedule.split(':');
      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final doseDateTime = today.add(Duration(hours: hour, minutes: minute));
      final doseKey = DateFormat('yyyy-MM-dd HH:mm').format(doseDateTime);

      final isTaken = medication.dosesTaken[doseKey] ?? false;
      final isMissed = doseDateTime.isBefore(now) && !isTaken;
      final isUpcoming = doseDateTime.isAfter(now) && !isTaken;

      if (isMissed) {
        missedDoseFound = true;
      }
      
      statusList.add(DoseStatus(
        scheduleTime: schedule,
        doseKey: doseKey,
        isTaken: isTaken,
        isMissed: isMissed,
        isUpcoming: isUpcoming,
      ));
    }
    
    // Atualiza o estado do widget para reconstruir com a cor e os botões corretos
    if (mounted) {
      setState(() {
        _hasMissedDose = missedDoseFound;
        _doseStatusList = statusList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpired = widget.medication.isExpired;
    
    // Define a cor do card com base na prioridade: Vencido > Dose Esquecida > Normal
    Color cardColor;
    if (isExpired) {
      cardColor = Colors.red.shade50;
    } else if (_hasMissedDose) {
      cardColor = Colors.yellow.shade100;
    } else {
      cardColor = Colors.white;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isExpired ? Colors.red.shade700 : Colors.transparent,
          width: 1.5,
        ),
      ),
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.medication_liquid, color: isExpired ? Colors.red.shade700 : AppColors.primary, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.medication.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isExpired ? Colors.red.shade900 : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dosagem: ${widget.medication.dosage}',
                        style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') widget.onEdit();
                    if (value == 'delete') widget.onDelete();
                    if (value == 'qr_code') widget.onViewOrGenerateQrCode();
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
            const Divider(height: 24, thickness: 1),
            
            // Seção de horários e status das doses
            if (_doseStatusList.isNotEmpty)
              ..._doseStatusList.map((status) => _buildDoseRow(status))
            else
              const Text("Nenhum horário definido."),
              
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

  // Constrói cada linha de horário
  Widget _buildDoseRow(DoseStatus status) {
    IconData icon;
    Color color;
    String statusText;

    if (status.isTaken) {
      icon = Icons.check_circle;
      color = Colors.green;
      statusText = 'Confirmado';
    } else if (status.isMissed) {
      icon = Icons.error;
      color = Colors.orange.shade800;
      statusText = 'Confirmação pendente';
    } else {
      icon = Icons.schedule;
      color = Colors.blueGrey;
      statusText = 'Próxima dose';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                '${status.scheduleTime} - $statusText',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          // Mostra o botão de confirmar apenas se a dose foi esquecida
          if (status.isMissed)
            ElevatedButton(
              onPressed: () => widget.onConfirmDose(status.doseKey),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Tomei'),
            ),
        ],
      ),
    );
  }
}
