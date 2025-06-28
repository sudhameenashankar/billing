import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../pdf_service.dart';

class ShareWhatsappButton extends StatelessWidget {
  final File pdfFile;
  const ShareWhatsappButton({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'whatsapp',
      icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
      label: const Text('WhatsApp'),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      onPressed: () async {
        await PdfService.sharePdf(pdfFile);
      },
    );
  }
}
