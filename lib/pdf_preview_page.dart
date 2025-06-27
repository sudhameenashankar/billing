import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';

class PdfPreviewPage extends StatelessWidget {
  final File pdfFile;
  const PdfPreviewPage({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(files: [XFile(pdfFile.path)], text: 'Invoice PDF'),
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(pdfFile),
    );
  }
}
