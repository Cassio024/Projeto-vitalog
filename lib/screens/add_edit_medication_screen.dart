// ARQUIVO CORRIGIDO E FINALIZADO: lib/screens/add_edit_medication_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';
import '../services/auth_service.dart';
import '../services/alarm_service.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final Medication? medication;
  const AddEditMedicationScreen({super.key, this.medication});

  @override
  _AddEditMedicationScreenState createState() =>
      _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  TimeOfDay? _startTime;
  List<String> _generatedSchedules = [];
  int? _selectedInterval;
  final List<int> _intervalOptions = [4, 6, 8, 12, 24];

  bool _isLoading = false;
  late String medicationId;
  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.medication?.name ?? '',
    );
    _dosageController = TextEditingController(
      text: widget.medication?.dosage ?? '',
    );

    if (widget.medication?.schedules != null &&
        widget.medication!.schedules.isNotEmpty) {
      _generatedSchedules = widget.medication!.schedules;
      final first = _generatedSchedules.first.split(':');
      if (first.length == 2) {
        _startTime = TimeOfDay(
          hour: int.parse(first[0]),
          minute: int.parse(first[1]),
        );
      }
    }

    _selectedInterval = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _generateSchedules();
      });
    }
  }

  void _generateSchedules() {
    if (_selectedInterval == null ||
        _startTime == null ||
        _selectedInterval == 0) {
      setState(() => _generatedSchedules = []);
      return;
    }

    List<String> schedules = [];
    int hour = _startTime!.hour;
    int minute = _startTime!.minute;

    for (int i = 0; i < (24 ~/ _selectedInterval!); i++) {
      schedules.add(
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      );
      hour = (hour + _selectedInterval!) % 24;
    }
    setState(() => _generatedSchedules = schedules);
  }

  Future<void> _pickInterval() async {
    final picked = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Escolher intervalo (em horas)'),
        children: _intervalOptions
            .map(
              (value) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, value),
                child: Text('$value horas'),
              ),
            )
            .toList(),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedInterval = picked;
        _generateSchedules();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Medicamento' : 'Adicionar Medicamento',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Medicamento',
                ),
                validator: (value) => value!.isEmpty ? 'Insira um nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosagem'),
                validator: (value) =>
                    value!.isEmpty ? 'Insira a dosagem' : null,
              ),
              const SizedBox(height: 16),
              // Campo Intervalo - estilizado
              InkWell(
                onTap: _pickInterval,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Intervalo (em horas)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    _selectedInterval == null
                        ? 'Toque para escolher'
                        : '$_selectedInterval horas',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Horário inicial - estilizado
              InkWell(
                onTap: _pickStartTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Horário Inicial',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    _startTime == null
                        ? 'Toque para escolher'
                        : '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(_isEditing ? 'Salvar Alterações' : 'Adicionar'),
                  onPressed: _isLoading ? null : () => _submitForm(),
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedInterval == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha o intervalo e o horário inicial!'),
        ),
      );
      return;
    }

    if (_generatedSchedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Os horários não foram gerados!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final medicationService = Provider.of<MedicationService>(
      context,
      listen: false,
    );
    final authService = Provider.of<AuthService>(context, listen: false);
    final alarmService = Provider.of<AlarmService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final currentMeds = await medicationService.getMedications(token);

      // CORREÇÃO: Criar lista de medicamentos para verificação de interações
      List<String> medNamesForCheck = [];

      if (_isEditing) {
        // Para edição: adicionar todos os medicamentos EXCETO o que está sendo editado
        medNamesForCheck = currentMeds
            .where((m) => m.id != widget.medication!.id)
            .map((m) => m.name)
            .toList();
        // Adicionar o novo nome do medicamento que está sendo editado
        medNamesForCheck.add(_nameController.text);
      } else {
        // Para adição: adicionar todos os medicamentos existentes
        medNamesForCheck = currentMeds.map((m) => m.name).toList();
        // Adicionar o novo medicamento
        medNamesForCheck.add(_nameController.text);
      }

      // Debug: imprimir a lista para verificação
      print('Medicamentos para verificação: $medNamesForCheck');

      // Verificar interações apenas se houver mais de 1 medicamento
      bool canProceed = true;
      if (medNamesForCheck.length > 1) {
        final interactionResult = await medicationService.checkInteractions(
          medNamesForCheck,
          token,
        );

        print('Resultado da API: $interactionResult'); // Debug adicional

        if (mounted && interactionResult['hasInteraction'] == true) {
          canProceed =
              await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('⚠️ Interação Medicamentosa Detectada!'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foram detectadas possíveis interações entre os medicamentos:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Medicamentos: ${medNamesForCheck.join(', ')}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Advertências:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...((interactionResult['warnings'] as List<dynamic>?)
                              ?.map(
                                (warning) => Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    top: 4.0,
                                  ),
                                  child: Text(
                                    '• $warning',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ) ??
                          []),
                      const SizedBox(height: 15),
                      const Text(
                        'Deseja continuar mesmo assim?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      child: const Text('Cancelar'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Continuar Mesmo Assim'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ) ??
              false;
        }
      }

      // Se o usuário cancelou, pare o processo
      if (!canProceed) {
        setState(() => _isLoading = false);
        return;
      }

      // Continuar com a lógica de salvar o medicamento
      final medicationData = {
        'name': _nameController.text,
        'dosage': _dosageController.text,
        'schedules': _generatedSchedules,
      };

      late String medicationId;
      if (_isEditing) {
        medicationId = widget.medication!.id;
        alarmService.cancelAlarmsForMedication(medicationId);
        await medicationService.updateMedication(
          medicationId,
          medicationData,
          token,
        );
      } else {
        final response = await medicationService.addMedication(
          medicationData,
          token,
        );
        medicationId = (response['id'] ?? response['_id'])?.toString() ?? '';
        if (medicationId == 'null' || medicationId.isEmpty) {
          throw Exception('ID inválido retornado pela API');
        }
      }

      final now = DateTime.now();
      final List<DateTime> alarmTimes = _generatedSchedules.map((timeStr) {
        final parts = timeStr.split(':');
        var time = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        if (time.isBefore(now)) time = time.add(const Duration(days: 1));
        return time;
      }).toList();

      if (alarmTimes.isNotEmpty && _selectedInterval != null) {
        alarmService.generateAlarms(
          medicationId: medicationId,
          medicationName: _nameController.text,
          startTime: alarmTimes.first,
          interval: Duration(hours: _selectedInterval!),
          count: alarmTimes.length,
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        print('ERRO NO SUBMITFORM: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
