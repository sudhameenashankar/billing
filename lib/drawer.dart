import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billing/pdf_preview_page.dart';
import 'dart:io';
import 'dart:convert';

class InvoiceDrawer extends StatefulWidget {
  const InvoiceDrawer({super.key});

  @override
  State<InvoiceDrawer> createState() => _InvoiceDrawerState();
}

class _InvoiceDrawerState extends State<InvoiceDrawer> {
  late Future<SharedPreferences> _prefsFuture;

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: _prefsFuture,
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
                    final updated = invoices.map((e) => jsonEncode(e)).toList();
                    await prefs.setStringList('saved_invoices', updated);
                    setState(() {});
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
