// Arquivo: lib/screens/add_edit_medication_screen.dart

import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final Medication? medication;
  const AddEditMedicationScreen({Key? key, this.medication}) : super(key: key);
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

  // CORREÇÃO: Lógica de envio unificada para adicionar e editar.
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final scheduleList = _schedules.split(',').map((e) => e.trim()).toList();
        
        // Declara a variável de resposta que será usada por ambos os casos.
        final Map<String, dynamic> response; 

        if (_isEditing) {
          // LÓGICA ADICIONADA: Chama o serviço de atualização.
          // É necessário que seu MedicationModel tenha um campo 'id'.
          response = await _medicationService.updateMedication(
            widget.medication!.id,
            _name,
            _dosage,
            scheduleList,
          );
        } else {
          // Lógica de adição existente.
          response = await _medicationService.addMedication(_name, _dosage, scheduleList);
        }
        
        // A extração do aviso e exibição do alerta agora é comum para ambos.
        final String? warning = response['warning'];

        if (warning != null && mounted) {
          await _showInteractionWarning(context, warning);
        }
        
        // Só executa o pop após o alerta ter sido (ou não) exibido.
        if (mounted) {
          Navigator.of(context).pop(true);
        }

      } catch (e) {
        if(mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
            );
        }
      }
    }
  }

  // Função existente para exibir o AlertDialog de interação.
  Future<void> _showInteractionWarning(BuildContext context, String warning) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário precisa confirmar para fechar.
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text('Atenção'),
            ],
          ),
          content: Text(warning),
          actions: <Widget>[
            TextButton(
              child: const Text('Entendi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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