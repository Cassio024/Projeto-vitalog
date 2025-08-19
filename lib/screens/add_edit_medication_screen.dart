// Arquivo: lib/screens/add_edit_medication_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/medication_model.dart';
import '../services/medication_service.dart';
import '../services/auth_service.dart';
import '../services/alarm_service.dart';
import 'scanner_screen.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final Medication? medication;

  const AddEditMedicationScreen({
    super.key,
    this.medication,
  });

  @override
  _AddEditMedicationScreenState createState() =>
      _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _expirationDateController;

  DateTime? _selectedExpirationDate;
  TimeOfDay? _startTime;
  List<String> _generatedSchedules = [];
  int? _selectedInterval;
  final List<int> _intervalOptions = [4, 6, 8, 12, 24];

  bool _isLoading = false;
  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?.name ?? '');
    _dosageController =
        TextEditingController(text: widget.medication?.dosage ?? '');

    if (widget.medication?.expirationDate != null) {
      _selectedExpirationDate = widget.medication!.expirationDate;
    }
    _expirationDateController = TextEditingController(
        text: _selectedExpirationDate != null
            ? DateFormat('dd/MM/yyyy').format(_selectedExpirationDate!)
            : '');

    if (widget.medication?.schedules != null &&
        widget.medication!.schedules.isNotEmpty) {
      _generatedSchedules = List.from(widget.medication!.schedules);
      try {
        final first = _generatedSchedules.first.split(':');
        if (first.length == 2) {
          _startTime =
              TimeOfDay(hour: int.parse(first[0]), minute: int.parse(first[1]));
        }
      } catch (e) {
        print("Erro ao analisar horário inicial: $e");
        _startTime = null;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  /// Abre a tela de scanner, busca o nome do produto pelo código de barras e preenche o campo.
  Future<void> _scanBarcode() async {
    final scannedCode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const ScannerScreen(isBarcodeMode: true),
      ),
    );

    if (scannedCode != null && mounted) {
      setState(() => _isLoading = true);
      final medicationService =
          Provider.of<MedicationService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.token;

      if (token != null) {
        final productName =
            await medicationService.getMedicationNameFromBarcode(scannedCode, token);
        if (productName != null) {
          setState(() {
            _nameController.text = productName;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nome do medicamento preenchido!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto não encontrado para este código de barras.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickExpirationDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedExpirationDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (pickedDate != null && pickedDate != _selectedExpirationDate) {
      setState(() {
        _selectedExpirationDate = pickedDate;
        _expirationDateController.text =
            DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _generateSchedules();
      });
    }
  }

  void _generateSchedules() {
    if (_selectedInterval == null || _startTime == null) {
      setState(() => _generatedSchedules = []);
      return;
    }

    List<String> schedules = [];
    int hour = _startTime!.hour;
    int minute = _startTime!.minute;

    for (int i = 0; i < (24 / _selectedInterval!); i++) {
      schedules.add(
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      hour = (hour + _selectedInterval!) % 24;
    }
    setState(() => _generatedSchedules = schedules);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios e o horário inicial.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final medicationService = Provider.of<MedicationService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final alarmService = Provider.of<AlarmService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final medicationData = {
        'name': _nameController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'schedules': _generatedSchedules,
        if (_selectedExpirationDate != null)
          'expirationDate': _selectedExpirationDate!.toIso8601String(),
      };

      late String medicationId;
      if (_isEditing) {
        medicationId = widget.medication!.id;
        await medicationService.updateMedication(medicationId, medicationData, token);
      } else {
        final response = await medicationService.addMedication(medicationData, token);
        medicationId = response['_id'] as String? ?? response['id'] as String? ?? const Uuid().v4();
      }

      alarmService.cancelAlarmsForMedication(medicationId);
      if (_generatedSchedules.isNotEmpty && _selectedInterval != null) {
        final now = DateTime.now();
        final firstScheduleTime = _generatedSchedules.first.split(':');
        final startTime = DateTime(now.year, now.month, now.day, int.parse(firstScheduleTime[0]), int.parse(firstScheduleTime[1]));

        alarmService.generateAlarms(
          medicationId: medicationId,
          medicationName: _nameController.text.trim(),
          startTime: startTime,
          interval: Duration(hours: _selectedInterval!),
          count: _generatedSchedules.length,
        );
      }
      
      if (mounted) Navigator.of(context).pop(true);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar medicamento: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Medicamento' : 'Adicionar Medicamento'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Medicamento',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.barcode_reader),
                    tooltip: 'Escanear Código de Barras',
                    onPressed: _scanBarcode,
                  ),
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
              TextFormField(
                controller: _expirationDateController,
                decoration: const InputDecoration(
                  labelText: 'Data de Validade (Opcional)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _pickExpirationDate,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedInterval,
                decoration: const InputDecoration(labelText: 'Intervalo (em horas)'),
                items: _intervalOptions
                    .map((h) => DropdownMenuItem(value: h, child: Text('$h horas')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedInterval = value;
                    _generateSchedules();
                  });
                },
                validator: (value) =>
                    value == null ? 'Escolha um intervalo' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Horário Inicial'),
                subtitle: Text(_startTime?.format(context) ?? 'Não definido'),
                trailing: const Icon(Icons.access_time),
                onTap: _pickStartTime,
              ),
              if (_generatedSchedules.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Horários gerados: ${_generatedSchedules.join(", ")}'),
                ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(_isEditing ? 'Salvar Alterações' : 'Adicionar Medicamento'),
                      onPressed: _submitForm,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
