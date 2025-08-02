// Arquivo: lib/screens/add_edit_medication_screen.dart
// MODIFICADO: Salva os dados na API real.

import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final Medication? medication;
  const AddEditMedicationScreen({super.key, this.medication});
  @override
  _AddEditMedicationScreenState createState() => _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final MedicationService _medicationService = MedicationService();
  bool _isLoading = false;
  late String _name;
  late String _dosage;
  late String _schedules;

  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    _name = widget.medication?.name ?? '';
    _dosage = widget.medication?.dosage ?? '';
    _schedules = widget.medication?.schedules.join(', ') ?? '';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final scheduleList = _schedules.split(',').map((e) => e.trim()).toList();

        if (_isEditing) {
          // Lógica de update (ainda não implementada no service, mas a estrutura está aqui)
        } else {
          await _medicationService.addMedication(_name, _dosage, scheduleList);
        }
        // Retorna 'true' para a tela anterior para sinalizar sucesso
        Navigator.of(context).pop(true);
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (build method com o formulário, mas o botão agora usa a nova lógica)
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Medicamento' : 'Adicionar Medicamento'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
             constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Nome do Medicamento'),
                      validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      onSaved: (v) => _name = v!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _dosage,
                      decoration: const InputDecoration(labelText: 'Dosagem (ex: 500mg)'),
                      validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      onSaved: (v) => _dosage = v!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _schedules,
                      decoration: const InputDecoration(labelText: 'Horários (ex: 08:00, 20:00)'),
                      validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      onSaved: (v) => _schedules = v!,
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(_isEditing ? 'Salvar Alterações' : 'Adicionar'),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}