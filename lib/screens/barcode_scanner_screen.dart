// Arquivo: lib/screens/barcode_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/medication_service.dart';
import '../services/auth_service.dart';
import '../models/medication_model.dart';
import '../widgets/medication_details_dialog.dart';

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    formats: [
      BarcodeFormat.ean13,    // Principal para medicamentos
      BarcodeFormat.ean8,     // Medicamentos menores
      BarcodeFormat.code128,  // Backup
    ],
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;
  
  // Debug info
  String _lastBarcode = '';
  int _scanCount = 0;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || !mounted) return;

    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final String? code = barcode.rawValue;
    
    _scanCount++;
    print('\n📊 BARCODE SCAN #$_scanCount');
    print('Código: $code');
    print('Formato: ${barcode.format}');
    
    if (code == null || code.isEmpty) return;

    // Validação específica para códigos de medicamentos
    if (!_isValidMedicationBarcode(code, barcode.format)) {
      _showError('Código de barras inválido para medicamento');
      return;
    }

    setState(() {
      _isProcessing = true;
      _lastBarcode = code;
    });

    _fetchMedicationByBarcode(code);
  }

  bool _isValidMedicationBarcode(String code, BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.ean13:
        return code.length == 13 && code.startsWith(RegExp(r'[0-9]'));
      case BarcodeFormat.ean8:
        return code.length == 8 && code.startsWith(RegExp(r'[0-9]'));
      case BarcodeFormat.code128:
        return code.length >= 6 && code.length <= 20;
      default:
        return false;
    }
  }

  Future<void> _fetchMedicationByBarcode(String barcode) async {
    final medicationService = Provider.of<MedicationService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      _showError('Erro de autenticação. Faça login novamente.');
      return;
    }

    try {
      print('Buscando medicamento por código de barras: $barcode');
      
      // IMPORTANTE: Verifique se existe método específico para barcode
      // Se não existir, pode ser que use o mesmo método do QR Code
      final Medication medication;
      
      // Opção 1: Se existe método específico para barcode
      // medication = await medicationService.getMedicationByBarcode(barcode, token);
      
      // Opção 2: Se usa o mesmo método (mais comum)
      medication = await medicationService.getMedicationByQRCode(barcode, token);
      
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => MedicationDetailsDialog(medication: medication),
        );
      }
    } catch (e) {
      print('Erro ao buscar por código de barras: $e');
      
      String errorMessage = 'Medicamento não encontrado';
      if (e.toString().contains('401')) {
        errorMessage = 'Erro de autenticação. Faça login novamente.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Medicamento não encontrado na base de dados.';
      } else if (e.toString().contains('connection') || e.toString().contains('timeout')) {
        errorMessage = 'Erro de conexão. Verifique sua internet.';
      }
      
      _showError(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _testManualSearch() {
    const testBarcode = "7891234567890";
    print('🧪 TESTE MANUAL: $testBarcode');
    setState(() {
      _isProcessing = true;
      _lastBarcode = testBarcode;
    });
    _fetchMedicationByBarcode(testBarcode);
  }

  @override
  Widget build(BuildContext context) {
    // Retângulo para código de barras
    final scanWindowWidth = MediaQuery.of(context).size.width * 0.85;
    final scanWindowHeight = scanWindowWidth * 0.6; // Proporção retangular
    
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: scanWindowWidth,
      height: scanWindowHeight,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código de Barras'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _testManualSearch,
            tooltip: 'Teste Manual',
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            scanWindow: scanWindow,
          ),
          
          // Retângulo para código de barras
          Container(
            width: scanWindowWidth,
            height: scanWindowHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.withOpacity(0.9), width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          // Debug info
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Scans: $_scanCount | Último: $_lastBarcode',
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Instruções específicas para código de barras
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Posicione o CÓDIGO DE BARRAS do medicamento\ndentro do retângulo azul\n\n'
                '• Códigos EAN13 (13 dígitos) são os mais comuns\n'
                '• Mantenha distância de 15-25cm\n'
                '• Certifique-se que está bem iluminado\n'
                '• Use o flash se necessário',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Buscando medicamento...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}