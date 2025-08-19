// Arquivo: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/medication_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/medication_service.dart';
import '../services/alarm_service.dart';
import '../widgets/medication_card.dart';
import '../widgets/qr_code_dialog.dart';
import 'add_edit_medication_screen.dart';
import 'scanner_screen.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Medication>>? _medicationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshMedications();
  }

  Future<void> _refreshMedications() async {
    final authService = Provider.of<AuthService>(context, listen: false);
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
    final alarmService = Provider.of<AlarmService>(context, listen: false);

    alarmService.cancelAlarmsForMedication(medicationId);

    if (authService.token == null) return;

    try {
      await medicationService.deleteMedication(
        medicationId,
        authService.token!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento apagado com sucesso!')),
        );
        _refreshMedications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao apagar medicamento: $e')),
        );
      }
    }
  }

  Future<void> _navigateToAddMedication() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddEditMedicationScreen()));
    if (result == true) {
      _refreshMedications();
    }
  }

  Future<void> _navigateToEditMedication(Medication medication) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditMedicationScreen(medication: medication),
      ),
    );
    if (result == true) {
      _refreshMedications();
    }
  }

  Future<void> _handleQrCodeAction(Medication medication) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final medicationService =
        Provider.of<MedicationService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de autenticação. Tente novamente.')),
      );
      return;
    }

    Medication medicationToShow = medication;
    bool needsRefresh = false;

    if (medication.qrCodeIdentifier == null) {
      final newIdentifier = const Uuid().v4();
      needsRefresh = true;
      try {
        await medicationService.updateMedication(
          medication.id,
          {'qrCodeIdentifier': newIdentifier},
          token,
        );
        medicationToShow = Medication(
            id: medication.id,
            name: medication.name,
            dosage: medication.dosage,
            schedules: medication.schedules,
            expirationDate: medication.expirationDate,
            qrCodeIdentifier: newIdentifier);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao gerar QR Code: ${e.toString()}')),
          );
        }
        return;
      }
    }

    showDialog(
      context: context,
      builder: (context) => QrCodeDialog(medication: medicationToShow),
    );

    if (needsRefresh) {
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
        title: Text('Olá ${user.name ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ScannerScreen()));
            },
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
            return const Center(
                child: Text('Nenhum medicamento cadastrado.'));
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
                  onEdit: () => _navigateToEditMedication(medication),
                  onDelete: () => _deleteMedication(medication.id),
                  onViewOrGenerateQrCode: () => _handleQrCodeAction(medication),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
            FloatingActionButton(
              heroTag: 'fab_add_medication',
              onPressed: _navigateToAddMedication,
              tooltip: 'Adicionar Medicamento',
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
