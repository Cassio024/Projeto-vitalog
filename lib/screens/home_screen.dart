// Arquivo: lib/screens/home_screen.dart
// MODIFICADO: Botão de logout agora é funcional.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication_model.dart';
import '../services/auth_service.dart';
import '../services/mock_api_service.dart';
import '../widgets/medication_card.dart';
import 'add_edit_medication_screen.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Medication>> _medicationsFuture;
  final MockApiService _apiService = MockApiService();

  @override
  void initState() {
    super.initState();
    _medicationsFuture = _apiService.getMedications();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Medicamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await authService.signOut();
              // O AuthWrapper cuidará da navegação para a tela de login
            },
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
            return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum medicamento cadastrado.'));
          }

          final medications = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              return MedicationCard(medication: medications[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditMedicationScreen()),
          );
        },
        tooltip: 'Adicionar Medicamento',
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
