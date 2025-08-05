// Arquivo: lib/screens/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/medication_service.dart';
import '../services/auth_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  void _handleQRCode(BarcodeCapture capture) {
    if (_isProcessing) return;
    final String? code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() { _isProcessing = true; });
    _scannerController.stop();

    final medicationService = Provider.of<MedicationService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final token = authService.token;
    if (token == null) {
      Navigator.of(context).pop();
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    medicationService.verifyAuthenticity(token, code).then((result) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(result['authentic'] == true ? 'Medicamento Autêntico' : 'Alerta'),
          content: Text(result['message'] ?? 'Não foi possível verificar.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  _scannerController.start();
                  setState(() { _isProcessing = false; });
                }
              },
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar Autenticidade')),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: _handleQRCode,
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}