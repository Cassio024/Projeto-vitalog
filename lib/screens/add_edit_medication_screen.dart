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
  _AddEditMedicationScreenState createState() => _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _schedulesController;

  bool _isLoading = false;
  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?.name ?? '');
    _dosageController = TextEditingController(text: widget.medication?.dosage ?? '');
    _schedulesController = TextEditingController(text: widget.medication?.schedules.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _schedulesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final medicationService = Provider.of<MedicationService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    try {
      // ----- INÍCIO DA MODIFICAÇÃO -----
      // O CÓDIGO DE VERIFICAÇÃO DE INTERAÇÕES FOI REATIVADO
      
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
      
      final interactionResult = await medicationService.checkInteractions(medNamesForCheck, token);

      bool canProceed = true;
      if (mounted && interactionResult['hasInteraction'] == true) {
        canProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Alerta!'),
            content: Text((interactionResult['warnings'] as List<dynamic>).join('\n')),
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
        ) ?? false;
      }
      
      // A linha "bool canProceed = true;" que estava aqui foi REMOVIDA
      // ----- FIM DA MODIFICAÇÃO -----

      if (canProceed) {
        final medicationData = {
          'name': _nameController.text,
          'dosage': _dosageController.text,
          'schedules': _schedulesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        };

        if (_isEditing) {
          await medicationService.updateMedication(widget.medication!.id, medicationData, token);
        } else {
          await medicationService.addMedication(medicationData, token);
        }

        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        print('ERRO NO SUBMITFORM: $e'); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Medicamento' : 'Adicionar Medicamento')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Medicamento'),
                validator: (value) => value!.isEmpty ? 'Insira um nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosagem'),
                validator: (value) => value!.isEmpty ? 'Insira a dosagem' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schedulesController,
                decoration: const InputDecoration(labelText: 'Horários (separados por vírgula)'),
                validator: (value) => value!.isEmpty ? 'Insira os horários' : null,
              ),
              const SizedBox(height: 32),
              _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(_isEditing ? 'Salvar Alterações' : 'Adicionar'),
                  )
            ],
          ),
        ),
      ),
    );
  }
}