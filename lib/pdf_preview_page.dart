import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final List<String> savedInvoices =
                  prefs.getStringList('saved_invoices') ?? [];
              final now = DateTime.now();
              final displayName =
                  'Invoice_${now.day}-${now.month}-${now.year}_${now.hour}${now.minute}${now.second}.pdf';
              final invoiceData = {
                'path': pdfFile.path,
                'name': displayName,
                'date': now.toIso8601String(),
              };
              final encoded = jsonEncode(invoiceData);
              ;
              if (!savedInvoices.contains(encoded)) {
                savedInvoices.add(encoded);
                await prefs.setStringList('saved_invoices', savedInvoices);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Invoice saved!')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice already saved.')),
                );
              }
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
            onPressed: () async {
              final url = "https://wa.me/";
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open WhatsApp')),
                );
              }
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(pdfFile),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.print),
        label: const Text('Print'),
        onPressed: () async {
          await Printing.layoutPdf(onLayout: (_) => pdfFile.readAsBytes());
        },
      ),
    );
  }
}
