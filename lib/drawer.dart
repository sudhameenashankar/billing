import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billing/pdf_preview_page.dart';
import 'dart:io';
import 'dart:convert';

class InvoiceDrawer extends StatelessWidget {
  const InvoiceDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final prefs = snapshot.data as SharedPreferences;
          final List<String> savedInvoices =
              prefs.getStringList('saved_invoices') ?? [];
          final invoices =
              savedInvoices.map((e) {
                final map = jsonDecode(e) as Map<String, dynamic>;
                return map;
              }).toList();
          return ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return ListTile(
                title: Text(invoice['name']),
                subtitle: Text(invoice['date']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    invoices.removeAt(index);
                    final updated = invoices.map((e) => e.toString()).toList();
                    await prefs.setStringList('saved_invoices', updated);
                    (context as Element).reassemble(); // Quick refresh
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => PdfPreviewPage(pdfFile: File(invoice['path'])),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
