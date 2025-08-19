// Arquivo: lib/widgets/qr_code_dialog.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/medication_model.dart';

class QrCodeDialog extends StatefulWidget {
  final Medication medication;

  const QrCodeDialog({super.key, required this.medication});

  @override
  State<QrCodeDialog> createState() => _QrCodeDialogState();
}

class _QrCodeDialogState extends State<QrCodeDialog> {
  double _qrSizeCm = 4.0;
  bool _isGeneratingPdf = false;

  /// Gera o PDF com o QR Code e abre a interface de impressão.
  Future<void> _generateAndPrintPdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfBytes = await _createPdfBytes();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'qrcode_vitalog_${widget.medication.name.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  /// Cria o conteúdo do PDF com todos os requisitos de layout.
  Future<Uint8List> _createPdfBytes() async {
    final doc = pw.Document();
    final qrImageData = await QrPainter(
      data: widget.medication.qrCodeIdentifier!,
      version: QrVersions.auto,
      gapless: false,
      // Muda a cor do QR Code para vermelho se estiver vencido.
      color: widget.medication.isExpired ? const Color(0xFFD32F2F) : const Color(0xFF000000),
      emptyColor: Colors.white,
    ).toImageData(300); // Aumenta a resolução para melhor qualidade no PDF

    if (qrImageData == null) {
      throw Exception('Não foi possível gerar a imagem do QR Code.');
    }

    final qrImage = pw.MemoryImage(qrImageData.buffer.asUint8List());
    final isExpired = widget.medication.isExpired;
    final textColor = isExpired ? PdfColors.red : PdfColors.black;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                // Container com a linha pontilhada.
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: isExpired ? PdfColors.red : PdfColors.grey,
                      width: 1,
                      style: pw.BorderStyle.dashed,
                    ),
                  ),
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text('VitaLog', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24, color: textColor)),
                      pw.SizedBox(height: 16),
                      pw.SizedBox(
                        width: (_qrSizeCm * PdfPageFormat.cm),
                        height: (_qrSizeCm * PdfPageFormat.cm),
                        child: pw.Image(qrImage),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        widget.medication.name,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 16, color: textColor, fontWeight: pw.FontWeight.bold),
                      ),
                       if(isExpired)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 8),
                          child: pw.Text(
                            'MEDICAMENTO VENCIDO',
                            style: pw.TextStyle(color: PdfColors.red, fontWeight: pw.FontWeight.bold)
                          )
                        )
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                // Instrução de corte fora da linha pontilhada.
                pw.Text(
                  'Recorte na linha pontilhada e cole na sua caixa de medicamento.',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    const double pixelsPerCm = 37.8;
    final double qrSizePixels = _qrSizeCm * pixelsPerCm;
    final bool isExpired = widget.medication.isExpired;

    return AlertDialog(
      title: const Text('QR Code do Medicamento'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // PopUp de aviso de medicamento vencido.
              if (isExpired)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ATENÇÃO: MEDICAMENTO VENCIDO!',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              // Container para colocar borda vermelha se o remédio estiver vencido.
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isExpired ? Colors.red.shade700 : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: QrImageView(
                  data: widget.medication.qrCodeIdentifier!,
                  version: QrVersions.auto,
                  size: qrSizePixels,
                  // Muda a cor do QR Code para vermelho se estiver vencido.
                  foregroundColor: isExpired ? Colors.red.shade700 : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Text('Tamanho: ${_qrSizeCm.round()} cm'),
              // Slider com novos limites (2 a 10 cm) e divisões inteiras.
              Slider(
                value: _qrSizeCm,
                min: 2.0,
                max: 10.0,
                divisions: 8, // 10 - 2 = 8 divisões de 1cm
                label: '${_qrSizeCm.round()} cm',
                onChanged: (double value) {
                  setState(() {
                    _qrSizeCm = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              // Texto de instrução atualizado conforme solicitado.
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!)
                ),
                child: const Text(
                  'Evite colocar um QR Code maior que a caixa ou deixar partes dele dobradas. Lembre-se: 2 a 4cm é para colar em caixas e cartelas, 5 a 7cm para caixas maiores e 8 a 10cm para colar em gavetas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (_isGeneratingPdf)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
        else
          TextButton(
            child: const Text('Fechar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        if (!_isGeneratingPdf)
          ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Gerar e Imprimir (PDF)'),
            onPressed: _generateAndPrintPdf,
          ),
      ],
    );
  }
}
