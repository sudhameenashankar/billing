import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'widgets/share_whatsapp_button.dart';
import 'widgets/print_button.dart';
import 'pdf_service.dart';

class PdfPreviewPage extends StatelessWidget {
  final File pdfFile;
  const PdfPreviewPage({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    // Set a width that fits your longest label, e.g., 120
    const double fabWidth = 120;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share,
              size: 30,
              color: Colors.deepPurpleAccent,
            ),
            onPressed: () async {
              await PdfService.sharePdf(pdfFile);
            },
          ),
          SizedBox(width: 16),
          IconButton(
            icon: const Icon(
              Icons.download,
              size: 30,
              color: Colors.blueAccent,
            ),
            onPressed: () async {
              final now = DateTime.now();
              final displayName =
                  'Invoice_${now.day}-${now.month}-${now.year}_${now.hour}${now.minute}${now.second}.pdf';
              await PdfService.savePdf(pdfFile, displayName);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Invoice saved!')));
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(pdfFile),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: fabWidth,
            child: ShareWhatsappButton(pdfFile: pdfFile),
          ),
          const SizedBox(height: 12),
          SizedBox(width: fabWidth, child: PrintButton(pdfFile: pdfFile)),
        ],
      ),
    );
  }
}
