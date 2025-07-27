// Arquivo: lib/screens/add_edit_medication_screen.dart
// (Sem alterações)
import 'package:flutter/material.dart';
import '../models/medication_model.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final Medication? medication;

  const AddEditMedicationScreen({Key? key, this.medication}) : super(key: key);

  @override
  _AddEditMedicationScreenState createState() => _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Medicamento' : 'Adicionar Medicamento'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    initialValue: _name,
                    decoration: const InputDecoration(labelText: 'Nome do Medicamento'),
                    validator: (value) => value!.isEmpty ? 'Por favor, insira um nome' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _dosage,
                    decoration: const InputDecoration(labelText: 'Dosagem (ex: 1 comprimido, 500mg)'),
                    validator: (value) => value!.isEmpty ? 'Por favor, insira a dosagem' : null,
                    onSaved: (value) => _dosage = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _schedules,
                    decoration: const InputDecoration(
                      labelText: 'Horários (separados por vírgula)',
                      hintText: 'ex: 08:00, 20:00',
                    ),
                    validator: (value) => value!.isEmpty ? 'Por favor, insira pelo menos um horário' : null,
                    onSaved: (value) => _schedules = value!,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(_isEditing ? 'Salvar Alterações' : 'Adicionar Medicamento'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
