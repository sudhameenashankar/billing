import 'package:billing/drawer.dart';
import 'package:billing/general_utility.dart';
import 'package:billing/item_model.dart';
import 'package:billing/pdf_preview_page.dart';
import 'package:billing/services';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:number_to_words/number_to_words.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

Future<File> _savePdfToFile(pw.Document pdf) async {
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/invoice.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Ramasamy Tex Invoice Generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<InvoiceItem> items = [];

  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();

  String _invoiceNumber = '';
  final DateTime _invoiceDate = DateTime.now();
  final _invoiceNumberController = TextEditingController();

  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerGstinController = TextEditingController();

  String _customerName = '';
  String _customerAddress = '';
  String _customerGstin = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList('invoice_item_names');
    if (names != null) {
      setState(() {
        items =
            names
                .map(
                  (name) => InvoiceItem(
                    nameOfProduct: name,
                    qty: 0,
                    rate: 0,
                    checked: false,
                  ),
                )
                .toList();
      });
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    // Save only the names
    final names = items.map((e) => e.nameOfProduct).toList();
    await prefs.setStringList('invoice_item_names', names);
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    // Only include checked items with qty > 0 and rate > 0
    final selected =
        items
            .where((item) => item.checked && item.qty > 0 && item.rate > 0)
            .toList();

    // 1. Calculate total amount
    final totalAmount = selected.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    // 2. Calculate taxes
    final sgst = (totalAmount * 0.025).round().toDouble();
    final cgst = (totalAmount * 0.025).round().toDouble();
    final netAmount = (totalAmount.round() + sgst + cgst).toDouble();

    // 3. Convert to words
    final netAmountWords =
        '${toPascalCase(NumberToWord().convert('en-in', netAmount.round()))} Rupees Only';

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(16),
        build:
            (pw.Context context) => pw.Container(
              padding: pw.EdgeInsets.all(16), // No extra padding inside
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          'GST IN : 33BKIPR1631K2Z2',
                          style: pw.TextStyle(fontSize: 10),
                          textAlign: pw.TextAlign.left,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.black,
                            width: 2,
                          ),
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'TAX INVOICE',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'CELL NO : 9344703477',
                          style: pw.TextStyle(fontSize: 10),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'RAMASAMY TEX,',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      pw.Text('39-A, RAJAGOUNDAMPALAYAM, STREET NO.6'),
                      pw.Text('TIRUCHENGODE - 637209, NAMAKKAL DT'),
                    ],
                  ),
                  pw.Divider(),
                  pw.Column(
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // LEFT BOX: Invoice details
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('INVOICE NO : $_invoiceNumber'),
                                pw.Text(
                                  'INVOICE DATE : '
                                  '${_invoiceDate.day.toString().padLeft(2, '0')}/'
                                  '${_invoiceDate.month.toString().padLeft(2, '0')}/'
                                  '${_invoiceDate.year}',
                                ),
                                pw.Divider(thickness: 1),
                                pw.Row(
                                  children: [
                                    pw.Text("State : Tamil Nadu"),
                                    pw.Container(
                                      width: 1,
                                      height: 14,
                                      color: PdfColors.grey700,
                                      margin: const pw.EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    pw.Text("State Code : 33"),
                                  ],
                                ),
                                pw.Divider(thickness: 1),
                                pw.Text(
                                  'To:',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 10),
                                pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      'Name:',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.SizedBox(width: 8),
                                    pw.Expanded(child: pw.Text(_customerName)),
                                  ],
                                ),
                                pw.SizedBox(height: 10),
                                pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      'Address:',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.SizedBox(width: 8),
                                    pw.Expanded(
                                      child: pw.Text(_customerAddress),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // VERTICAL DIVIDER
                          pw.Container(
                            width: 1.2,
                            height: 170, // Adjust height as needed
                            color: PdfColors.grey700,
                          ),
                          // RIGHT BOX: Transport and order details
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Transport Mode: ROAD'),
                                pw.Divider(thickness: 1),
                                pw.Text('Vehicle No:'),
                                pw.Divider(thickness: 1),
                                pw.Text('Document Through: MINI TEMPO'),
                                pw.Divider(thickness: 1),
                                // Purchase Order No and Date in a row
                                pw.Row(
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text(
                                        'Purchase Order No: $_invoiceNumber',
                                      ),
                                    ),
                                    pw.Container(
                                      width: 1,
                                      height: 14,
                                      color: PdfColors.grey700,
                                      margin: const pw.EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        'Date: '
                                        '${_invoiceDate.day.toString().padLeft(2, '0')}/'
                                        '${_invoiceDate.month.toString().padLeft(2, '0')}/'
                                        '${_invoiceDate.year}',
                                      ),
                                    ),
                                  ],
                                ),
                                pw.Divider(thickness: 1),
                                pw.Text('GSTIN: $_customerGstin'),
                                pw.Divider(thickness: 1),
                                // State and State Code in a row
                                pw.Row(
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text('State: TAMIL NADU'),
                                    ),
                                    pw.Container(
                                      width: 1,
                                      height: 14,
                                      color: PdfColors.grey700,
                                      margin: const pw.EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text('State Code: 33'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.Divider(
                        thickness: 1,
                      ), // Continuous line under both boxes
                      pw.Container(
                        constraints: pw.BoxConstraints(minHeight: 300),
                        child: pw.Table(
                          border: pw.TableBorder.all(
                            color: PdfColors.grey700,
                            width: 1,
                          ),
                          columnWidths: {
                            0: pw.FlexColumnWidth(1), // S No
                            1: pw.FlexColumnWidth(5), // Name of the Product
                            2: pw.FlexColumnWidth(2), // HSN / ACS
                            3: pw.FlexColumnWidth(1), // Qty
                            4: pw.FlexColumnWidth(2), // Rate
                            5: pw.FlexColumnWidth(2), // Amount
                          },
                          children: [
                            // Header row
                            pw.TableRow(
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey300,
                              ),
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    'S No:',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    'Name of the Product:',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    'HSN / ACS:',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    'Qty',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    'Rate:',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    'Amount\n(RS):',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Data rows
                            ...selected.asMap().entries.map((entry) {
                              int idx = entry.key + 1;
                              var item = entry.value;
                              return pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('$idx'),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text(item.nameOfProduct),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text(
                                      item.hsnOrAcs.toString(),
                                    ), // Add HSN/ACS to your items if needed
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text(
                                      item.qty.toString(),
                                    ), // Add qty to your items if needed
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text(item.rate.toString()),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text(item.amount.toString()),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      pw.Divider(thickness: 1),
                    ],
                  ),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // LEFT BOX (60%)
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Total Tax Amount (in words)'),
                            pw.SizedBox(height: 20),
                            pw.Text(
                              '${toPascalCase(NumberToWord().convert('en-in', (sgst + cgst).round()))} Rupees Only',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            pw.SizedBox(height: 30),
                            pw.Text('Total Invoice Amount (in words)'),
                            pw.SizedBox(height: 20),
                            pw.Text(
                              netAmountWords,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // VERTICAL DIVIDER
                      pw.Container(
                        width: 1,
                        margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                        height:
                            140, // Adjust height as needed to match the tallest box
                        color: PdfColors.black,
                      ),
                      // RIGHT BOX (40%)
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: [
                            pw.Row(
                              children: [
                                pw.Expanded(child: pw.Text('Total Amount:')),
                                pw.Text(
                                  totalAmount.toStringAsFixed(2),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ],
                            ),
                            pw.Divider(
                              thickness: 0.5,
                              color: PdfColors.grey400,
                            ),
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Text('Add C GST (2.5%):'),
                                ),
                                pw.Text(
                                  cgst.toString(),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ],
                            ),
                            pw.Divider(
                              thickness: 0.5,
                              color: PdfColors.grey400,
                            ),
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Text('Add S GST (2.5%):'),
                                ),
                                pw.Text(
                                  sgst.toString(),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ],
                            ),
                            pw.Divider(
                              thickness: 0.5,
                              color: PdfColors.grey400,
                            ),
                            pw.Row(
                              children: [
                                pw.Expanded(child: pw.Text('Add I GST:')),
                                pw.Text('0.00', textAlign: pw.TextAlign.right),
                              ],
                            ),
                            pw.Divider(
                              thickness: 0.5,
                              color: PdfColors.grey400,
                            ),
                            pw.Row(
                              children: [
                                pw.Expanded(child: pw.Text('Net Amount:')),
                                pw.Text(
                                  netAmount.toString(),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ],
                            ),
                            pw.Divider(
                              thickness: 0.5,
                              color: PdfColors.grey400,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(thickness: 1),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    padding: const pw.EdgeInsets.all(8),
                    margin: const pw.EdgeInsets.only(top: 12),
                    height:
                        140, // <-- Increased height for more signature space
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        // LEFT BOX: Bank Details
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            alignment: pw.Alignment.topLeft,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'BANK DETAILS :',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text('Bank Name : TMB, Tiruchengode Branch'),
                                pw.SizedBox(height: 8),
                                pw.Text('Ac No: 126150050801535'),
                                pw.SizedBox(height: 8),
                                pw.Text('IFSC No : TMBL0000126'),
                              ],
                            ),
                          ),
                        ),
                        // VERTICAL DIVIDER with margin
                        pw.Container(
                          width: 1,
                          margin: const pw.EdgeInsets.symmetric(horizontal: 12),
                          color: PdfColors.black,
                        ),
                        // RIGHT BOX: Certificate & Signature
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            alignment: pw.Alignment.topLeft,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Certificate that the particulars given above are true and correct',
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                                pw.SizedBox(height: 12),
                                pw.Text(
                                  'For RAMASAMY TEX,',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 60,
                                ), // More space for signature
                                pw.Text(
                                  'Authorised Signatory',
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );

    final file = await _savePdfToFile(pdf);

    // Navigate to PDF preview with zoom and share
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PdfPreviewPage(pdfFile: file)),
      );
    }
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
    _saveItems();
  }

  void _addNewItem(String name, int qty, double rate) {
    setState(() {
      items.add(
        InvoiceItem(
          nameOfProduct: name,
          qty: qty,
          rate: rate,
          checked: false, // Default to unchecked
        ),
      );
    });
    _saveItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: InvoiceDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice Number
                      TextFormField(
                        controller: _invoiceNumberController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [UpperCaseTextFormatter()],
                        decoration: InputDecoration(
                          labelText: 'Invoice Number',
                        ),
                        validator:
                            (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Enter Invoice Number'
                                    : null,
                        onChanged:
                            (val) => setState(() => _invoiceNumber = val),
                      ),
                      SizedBox(height: 16),
                      // Name
                      TextFormField(
                        controller: _customerNameController,
                        decoration: InputDecoration(labelText: 'Name'),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [UpperCaseTextFormatter()],
                        validator:
                            (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Enter Name'
                                    : null,
                        onChanged: (val) => setState(() => _customerName = val),
                      ),
                      SizedBox(height: 8),
                      // Address
                      TextFormField(
                        controller: _customerAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          alignLabelWithHint:
                              true, // aligns label at the top for multiline
                        ),
                        maxLines: 6, // or any number you prefer
                        minLines: 3, // optional, for minimum height
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [UpperCaseTextFormatter()],
                        validator:
                            (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Enter Address'
                                    : null,
                        onChanged:
                            (val) => setState(() => _customerAddress = val),
                      ),
                      SizedBox(height: 8),
                      // GSTIN
                      TextFormField(
                        controller: _customerGstinController,
                        decoration: InputDecoration(labelText: 'GSTIN'),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [UpperCaseTextFormatter()],
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter GSTIN';
                          }
                          final gstinRegex = RegExp(
                            r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
                          );
                          if (!gstinRegex.hasMatch(val.trim())) {
                            return 'Enter valid GSTIN';
                          }
                          return null;
                        },
                        onChanged:
                            (val) => setState(() => _customerGstin = val),
                      ),
                      SizedBox(height: 16),
                      // ...rest of your widgets...
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select items for billing:',
                  style: TextStyle(fontSize: 18),
                ),
                ...items.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var item = entry.value;
                  return Row(
                    children: [
                      Checkbox(
                        value: item.checked,
                        onChanged: (val) {
                          setState(() {
                            item.checked = val!;
                          });
                        },
                      ),
                      Expanded(child: Text(item.nameOfProduct)),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          initialValue:
                              item.qty == 0 ? '' : item.qty.toString(),
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [UpperCaseTextFormatter()],
                          decoration: const InputDecoration(labelText: 'Qty'),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            setState(() {
                              item.qty = int.tryParse(val) ?? 0;
                            });
                            _saveItems();
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue:
                              item.rate == 0 ? '' : item.rate.toString(),
                          decoration: const InputDecoration(labelText: 'Rate'),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            setState(() {
                              item.rate = double.tryParse(val) ?? 0;
                            });
                            _saveItems();
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(idx),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.picture_as_pdf, size: 24),
                      label: const Text('Generate PDF'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Check that all checked items have qty > 0 and rate > 0
                          final invalidChecked =
                              items
                                  .where(
                                    (item) =>
                                        item.checked &&
                                        (item.qty == 0 || item.rate == 0),
                                  )
                                  .toList();
                          if (invalidChecked.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'All selected items must have Quantity and Rate greater than 0.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          _generatePdf();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Add new item:', style: TextStyle(fontSize: 18)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                        inputFormatters: [UpperCaseTextFormatter()],
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _qtyController,
                        decoration: InputDecoration(labelText: 'Qty'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _rateController,
                        decoration: InputDecoration(labelText: 'Rate'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        final name = _nameController.text;
                        final qty = int.tryParse(_qtyController.text) ?? 0;
                        final rate = double.tryParse(_rateController.text) ?? 0;
                        if (name.isNotEmpty && qty > 0 && rate > 0) {
                          _addNewItem(name, qty, rate);
                          _nameController.clear();
                          _qtyController.clear();
                          _rateController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
