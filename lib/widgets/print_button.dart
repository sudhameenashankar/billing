import 'dart:io';
import 'package:flutter/material.dart';
import '../pdf_service.dart';

class PrintButton extends StatelessWidget {
  final File pdfFile;
  const PrintButton({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'print',
      icon: const Icon(Icons.print),
      label: const Text('Print'),
      onPressed: () async {
        await PdfService.printPdf(pdfFile);
      },
    );
  }
}
