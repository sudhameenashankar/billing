import 'package:billing/item_model.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  List<InvoiceItem> items = [
    InvoiceItem(nameOfProduct: "Item 1", qty: 2, rate: 100),
    InvoiceItem(nameOfProduct: "Item 2", qty: 1, rate: 200),
    InvoiceItem(nameOfProduct: "Item 3", qty: 3, rate: 300),
  ];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final selected = items.where((item) => item.checked).toList();

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(16), // Minimal margin from page edge
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
                          'GST IN : 33BKIPR1631K1Z3',
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
                                pw.Text('INVOICE NO : 12345'),
                                pw.Text('INVOICE DATE : 01/01/2023'),
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
                                pw.Container(
                                  width: double.infinity,
                                  height: 70, // Adjust height as needed
                                  // child: pw.Text(''), // Leave empty for now, fill later
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
                                pw.Text('Transport Mode:'),
                                pw.Divider(thickness: 1),
                                pw.Text('Vehicle No:'),
                                pw.Divider(thickness: 1),
                                pw.Text('Document Through:'),
                                pw.Divider(thickness: 1),
                                // Purchase Order No and Date in a row
                                pw.Row(
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text('Purchase Order No:'),
                                    ),
                                    pw.Container(
                                      width: 1,
                                      height: 14,
                                      color: PdfColors.grey700,
                                      margin: const pw.EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    pw.Expanded(child: pw.Text('Date:')),
                                  ],
                                ),
                                pw.Divider(thickness: 1),
                                pw.Text('GSTIN:'),
                                pw.Divider(thickness: 1),
                                // State and State Code in a row
                                pw.Row(
                                  children: [
                                    pw.Expanded(child: pw.Text('State:')),
                                    pw.Container(
                                      width: 1,
                                      height: 14,
                                      color: PdfColors.grey700,
                                      margin: const pw.EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    pw.Expanded(child: pw.Text('State Code:')),
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
                            pw.SizedBox(height: 16),
                            pw.Container(
                              margin: const pw.EdgeInsets.symmetric(
                                vertical: 2,
                              ),
                              child: pw.Divider(
                                thickness: 1,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 30),
                            pw.Text('Total Invoice Amount (in words)'),
                            pw.SizedBox(height: 16),
                            pw.Container(
                              margin: const pw.EdgeInsets.symmetric(
                                vertical: 2,
                              ),
                              child: pw.Divider(
                                thickness: 1,
                                color: PdfColors.grey700,
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
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Total Amount:'),
                            pw.Divider(
                              thickness: 0.5,
                              color: PdfColors.grey400,
                            ),
                            pw.Text('Add C GST:'),
                            pw.Divider(
                              thickness: 0.5,
                              color: PdfColors.grey400,
                            ),
                            pw.Text('Add S GST:'),
                            pw.Divider(
                              thickness: 0.5,
                              color: PdfColors.grey400,
                            ),
                            pw.Text('Add I GST:'),
                            pw.Divider(
                              thickness: 0.5,
                              color: PdfColors.grey400,
                            ),
                            pw.Text('Net Amount:'),
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
                                pw.Text('Ac No: 126150050801310'),
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

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Select items for billing:',
              style: TextStyle(fontSize: 18),
            ),
            ...items.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              return CheckboxListTile(
                title: Text('${item.nameOfProduct} (₹${item.rate})'),
                value: item.checked,
                onChanged: (val) {
                  setState(() {
                    item.checked = val!;
                  });
                },
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generatePdf,
              child: const Text('Generate PDF'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
