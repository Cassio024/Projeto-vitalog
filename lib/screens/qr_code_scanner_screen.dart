// Arquivo: lib/screens/qr_code_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/medication_service.dart';
import '../services/auth_service.dart';
import '../models/medication_model.dart';
import '../widgets/medication_details_dialog.dart';

class QrCodeScannerScreen extends StatefulWidget {
  // ADICIONADO: Parâmetro para diferenciar os modos
  final bool isBarcodeMode;

  // MODIFICADO: Construtor para aceitar o novo parâmetro
  const QrCodeScannerScreen({
    super.key,
    this.isBarcodeMode = false,
  });

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
  // MODIFICADO: Controller inicializado em initState para ser dinâmico
  late final MobileScannerController _scannerController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // MODIFICADO: Define os formatos de código com base no modo
    _scannerController = MobileScannerController(
      formats: widget.isBarcodeMode
          ? [BarcodeFormat.all] // Permite todos os tipos de código de barras
          : [BarcodeFormat.qrCode], // Permite apenas QR Code
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || !mounted) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final String? detectedCode = barcode.rawValue;

    if (detectedCode == null || detectedCode.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // MODIFICADO: Lógica para diferenciar a ação com base no modo
    if (widget.isBarcodeMode) {
      // No modo de código de barras, apenas retorna o código lido
      Navigator.of(context).pop(detectedCode);
    } else {
      // No modo de QR Code, busca o medicamento
      print('QR Code detectado: $detectedCode');
      _fetchMedicationByQRCode(detectedCode);
    }
  }

  Future<void> _fetchMedicationByQRCode(String qrIdentifier) async {
    final medicationService = Provider.of<MedicationService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      _showError('Erro de autenticação. Faça login novamente.');
      return;
    }

    try {
      print('Buscando medicamento por QR Code: $qrIdentifier');
      final Medication medication = await medicationService.getMedicationByQRCode(qrIdentifier, token);
      
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => MedicationDetailsDialog(medication: medication),
        );
      }
    } catch (e) {
      print('Erro ao buscar por QR Code: $e');
      
      String errorMessage = 'QR Code não encontrado';
      if (e.toString().contains('401')) {
        errorMessage = 'Erro de autenticação. Faça login novamente.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'QR Code não encontrado na base de dados.';
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

  @override
  Widget build(BuildContext context) {
    final scanWindowSize = MediaQuery.of(context).size.width * 0.7;
    
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    // MODIFICADO: Textos da UI dinâmicos com base no modo
    final String appBarTitle = widget.isBarcodeMode ? 'Escanear Código de Barras' : 'Escanear QR Code';
    final String instructionText = widget.isBarcodeMode
        ? 'Posicione o CÓDIGO DE BARRAS dentro do quadrado verde'
        : 'Posicione o QR CODE dentro do quadrado verde\n\n'
          '• QR Code deve estar bem visível\n'
          '• Mantenha distância de 20-30cm\n'
          '• Use o flash se necessário';
    final String processingText = widget.isBarcodeMode ? 'Processando Código...' : 'Processando QR Code...';

    return Scaffold(
      appBar: AppBar(
        // MODIFICADO: Título dinâmico
        title: Text(appBarTitle),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _scannerController.toggleTorch(),
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
          
          Container(
            width: scanWindowSize,
            height: scanWindowSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green.withOpacity(0.9), width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
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
              // MODIFICADO: Instruções dinâmicas
              child: Text(
                instructionText,
                style: const TextStyle(
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.green),
                    const SizedBox(height: 16),
                    // MODIFICADO: Texto de processamento dinâmico
                    Text(
                      processingText,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
