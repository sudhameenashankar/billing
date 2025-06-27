import 'dart:io';

import 'package:billing/pdf_preview_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedInvoicesPage extends StatefulWidget {
  const SavedInvoicesPage({super.key});

  @override
  State<SavedInvoicesPage> createState() => _SavedInvoicesPageState();
}

class _SavedInvoicesPageState extends State<SavedInvoicesPage> {
  List<String> savedInvoices = [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedInvoices = prefs.getStringList('saved_invoices') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Invoices')),
      body: ListView.builder(
        itemCount: savedInvoices.length,
        itemBuilder: (context, index) {
          final path = savedInvoices[index];
          return ListTile(
            title: Text('Invoice ${index + 1}'),
            subtitle: Text(path),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfPreviewPage(pdfFile: File(path)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
