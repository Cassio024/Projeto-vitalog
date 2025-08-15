// ARQUIVO CORRIGIDO E FINALIZADO: lib/screens/add_edit_medication_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';
import '../services/auth_service.dart';

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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
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
      setState(() {
        _generatedSchedules = [];
      });
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

    setState(() {
      _generatedSchedules = schedules;
    });
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
    final token = authService.token;

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final currentMeds = await medicationService.getMedications(token);
      final List<String> medNamesForCheck = currentMeds.map((m) {
        if (_isEditing && m.id == widget.medication!.id) {
          return _nameController.text;
        }
        return m.name;
      }).toList();

      if (!_isEditing) {
        medNamesForCheck.add(_nameController.text);
      }

      final interactionResult = await medicationService.checkInteractions(
        medNamesForCheck,
        token,
      );

      bool canProceed = true;
      if (mounted && interactionResult['hasInteraction'] == true) {
        canProceed =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Alerta!'),
                content: Text(
                  (interactionResult['warnings'] as List<dynamic>).join('\n'),
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: const Text('Continuar Mesmo Assim'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ) ??
            false;
      }

      if (canProceed) {
        final medicationData = {
          'name': _nameController.text,
          'dosage': _dosageController.text,
          'schedules': _generatedSchedules,
        };

        if (_isEditing) {
          await medicationService.updateMedication(
            widget.medication!.id,
            medicationData,
            token,
          );
        } else {
          await medicationService.addMedication(medicationData, token);
        }

        if (mounted) Navigator.of(context).pop(true);
      }
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

  Future<void> _pickInterval() async {
    final picked = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Escolher intervalo (em horas)'),
        children: _intervalOptions.map((value) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, value),
            child: Text('$value horas'),
          );
        }).toList(),
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
                    labelText: 'Horário inicial',
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
              const SizedBox(height: 16),

              // Remova a exibição dos horários gerados:
              // if (_generatedSchedules.isNotEmpty)
              //   Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       ..._generatedSchedules.map((h) => Text(h)).toList(),
              //     ],
              //   ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(
                        _isEditing
                            ? 'Salvar Alterações'
                            : 'Adicionar Medicamento',
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
