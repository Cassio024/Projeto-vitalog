// Arquivo: lib/screens/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/medication_service.dart';
import '../services/auth_service.dart';
import '../models/medication_model.dart';
import '../widgets/medication_details_dialog.dart';

class ScannerScreen extends StatefulWidget {
  /// Define o modo de operação do scanner.
  /// Se true, ele retorna o código de barras lido como uma string.
  /// Se false (padrão), ele busca os dados do medicamento pelo QR Code.
  final bool isBarcodeMode;

  const ScannerScreen({super.key, this.isBarcodeMode = false});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    // Otimiza o scanner para os tipos de código que usamos.
    formats: [
      BarcodeFormat.qrCode,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.code128
    ],
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// Lógica unificada para lidar com códigos lidos.
  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || !mounted) return;

    final String? code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // Decide o que fazer com base no modo do scanner.
    if (widget.isBarcodeMode) {
      // Modo Código de Barras: apenas retorna o código para a tela anterior.
      Navigator.of(context).pop(code);
    } else {
      // Modo QR Code: busca os dados do medicamento.
      _fetchMedicationDetails(code);
    }
  }

  /// Busca os detalhes do medicamento na API e exibe o pop-up.
  Future<void> _fetchMedicationDetails(String qrIdentifier) async {
    final medicationService = Provider.of<MedicationService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      _showErrorAndResume('Erro de autenticação.');
      return;
    }

    try {
      final Medication medication = await medicationService.getMedicationByQRCode(qrIdentifier, token);
      
      if (mounted) {
        // Mostra o PopUp com os detalhes do medicamento.
        await showDialog(
          context: context,
          builder: (context) => MedicationDetailsDialog(medication: medication),
        );
      }
    } catch (e) {
      _showErrorAndResume('Medicamento não encontrado ou erro na busca.');
    } finally {
      // Permite escanear novamente após fechar o dialog.
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Exibe uma mensagem de erro e reativa o scanner.
  void _showErrorAndResume(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isBarcodeMode ? 'Escanear Código de Barras' : 'Escanear QR Code'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // Adiciona uma sobreposição visual para guiar o usuário.
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
