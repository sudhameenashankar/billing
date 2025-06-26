class InvoiceItem {
  final String nameOfProduct;
  final String hsnOrAcs;
  int qty;
  double rate;
  bool checked;

  InvoiceItem({
    required this.nameOfProduct,
    this.hsnOrAcs = '5208',
    required this.qty,
    required this.rate,
    this.checked = false,
  });

  double get amount => qty * rate;

  Map<String, dynamic> toJson() => {
    'nameOfProduct': nameOfProduct,
    'hsnOrAcs': hsnOrAcs,
    'qty': qty,
    'rate': rate,
    'checked': checked,
  };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    nameOfProduct: json['nameOfProduct'],
    hsnOrAcs: json['hsnOrAcs'] ?? '5208',
    qty: json['qty'],
    rate: (json['rate'] as num).toDouble(),
    checked: json['checked'] ?? false,
  );
}
