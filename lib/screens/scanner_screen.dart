// Arquivo: lib/screens/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/medication_service.dart';
import '../services/auth_service.dart';
import '../models/medication_model.dart';
import '../widgets/medication_details_dialog.dart';

class ScannerScreen extends StatefulWidget {
  final bool isBarcodeMode;

  const ScannerScreen({super.key, this.isBarcodeMode = false});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
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

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || !mounted) return;

    final String? code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    if (widget.isBarcodeMode) {
      Navigator.of(context).pop(code);
    } else {
      _fetchMedicationDetails(code);
    }
  }

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
        await showDialog(
          context: context,
          builder: (context) => MedicationDetailsDialog(medication: medication),
        );
      }
    } catch (e) {
      _showErrorAndResume('Medicamento não encontrado ou erro na busca.');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

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
    final scanWindowSize = MediaQuery.of(context).size.width * 0.7;
    
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: scanWindowSize,
      height: scanWindowSize,
    );

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
            scanWindow: scanWindow,
          ),
          Container(
            width: scanWindowSize,
            height: scanWindowSize,
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
