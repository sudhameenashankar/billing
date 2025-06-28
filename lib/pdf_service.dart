import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> sharePdf(File pdfFile, {String? text}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(pdfFile.path)], text: text ?? 'Invoice PDF'),
    );
  }

  static Future<void> savePdf(File pdfFile, String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedInvoices =
        prefs.getStringList('saved_invoices') ?? [];
    final now = DateTime.now();
    final invoiceData = {
      'path': pdfFile.path,
      'name': displayName,
      'date': now.toIso8601String(),
    };
    final encoded = jsonEncode(invoiceData);
    if (!savedInvoices.contains(encoded)) {
      savedInvoices.add(encoded);
      await prefs.setStringList('saved_invoices', savedInvoices);
    }
  }

  static Future<void> printPdf(File pdfFile) async {
    await Printing.layoutPdf(onLayout: (_) => pdfFile.readAsBytes());
  }
}
