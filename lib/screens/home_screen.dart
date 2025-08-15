// ARQUIVO ATUALIZADO: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/medication_service.dart';
import '../widgets/medication_card.dart';
import 'add_edit_medication_screen.dart';
import 'scanner_screen.dart';
import 'chatbot_screen.dart'; // <-- ADICIONADO

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Medication>>? _medicationsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshMedications();
  }

  Future<void> _refreshMedications() async {
    final authService = Provider.of<AuthService>(context, listen: true);
    final medicationService = Provider.of<MedicationService>(
      context,
      listen: false,
    );
    if (authService.token != null) {
      setState(() {
        _medicationsFuture = medicationService.getMedications(
          authService.token!,
        );
      });
    }
  }

  Future<void> _deleteMedication(String medicationId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final medicationService = Provider.of<MedicationService>(
      context,
      listen: false,
    );

    if (authService.token == null) return;

    try {
      await medicationService.deleteMedication(
        medicationId,
        authService.token!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento deletado com sucesso!')),
        );
      }
      _refreshMedications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao deletar medicamento: $e')),
        );
      }
    }
  }

  Future<void> _navigateToEditScreen(Medication medication) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditMedicationScreen(medication: medication),
      ),
    );
    if (result == true) {
      _refreshMedications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: true);
    final user = Provider.of<UserModel?>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Olá ${user.name ?? ''}',
          style: const TextStyle(color: Color.fromARGB(255, 250, 250, 250)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ScannerScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: FutureBuilder<List<Medication>>(
        future: _medicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar dados: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum medicamento cadastrado.'));
          }
          final medications = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshMedications,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final medication = medications[index];
                return MedicationCard(
                  medication: medication,
                  onEdit: () => _navigateToEditScreen(medication),
                  onDelete: () => _deleteMedication(medication.id),
                );
              },
            ),
          );
        },
      ),
      // ----- BLOCO ATUALIZADO -----
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botão para o Chatbot
            FloatingActionButton(
              heroTag: 'fab_chatbot',
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
              },
              tooltip: 'Abrir Chatbot',
              child: const Icon(Icons.support_agent),
            ),

            const SizedBox(width: 10),

            // Botão para Adicionar Medicamento
            FloatingActionButton(
              heroTag: 'fab_add_medication',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddEditMedicationScreen(),
                  ),
                );
                if (result == true) {
                  _refreshMedications();
                }
              },
              tooltip: 'Adicionar Medicamento',
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
