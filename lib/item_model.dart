class InvoiceItem {
  final String nameOfProduct;
  final String hsnOrAcs;
  final int qty;
  final double rate;
  bool checked;

  InvoiceItem({
    required this.nameOfProduct,
    this.hsnOrAcs = '5208',
    required this.qty,
    required this.rate,
    this.checked = false,
  });

  double get amount => qty * rate;
}
