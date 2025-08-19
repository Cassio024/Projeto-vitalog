// lib/screens/scanner_screen.dart - Wrapper de compatibilidade
import 'package:flutter/material.dart';
import 'qr_code_scanner_screen.dart';
import 'barcode_scanner_screen.dart';

class ScannerScreen extends StatelessWidget {
  final bool isBarcodeMode;

  const ScannerScreen({super.key, this.isBarcodeMode = false});

  @override
  Widget build(BuildContext context) {
    if (isBarcodeMode) {
      return const BarcodeScreen();
    } else {
      return const QrCodeScannerScreen();
    }
  }
}
