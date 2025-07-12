import 'package:flutter/material.dart';
import 'package:billing/item_model.dart';

class ItemsListSection extends StatelessWidget {
  final List<InvoiceItem> items;
  final Function(int) onDeleteItem;
  final Function(int, int) onQtyChanged;
  final Function(int, double) onRateChanged;
  final Function(int, bool) onCheckedChanged;

  const ItemsListSection({
    super.key,
    required this.items,
    required this.onDeleteItem,
    required this.onQtyChanged,
    required this.onRateChanged,
    required this.onCheckedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select items for billing:', style: TextStyle(fontSize: 18)),
        ...items.asMap().entries.map((entry) {
          int idx = entry.key;
          var item = entry.value;
          return Row(
            children: [
              Checkbox(
                value: item.checked,
                onChanged: (val) => onCheckedChanged(idx, val!),
              ),
              Expanded(child: Text(item.nameOfProduct)),
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: item.qty == 0 ? '' : item.qty.toString(),
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Qty'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => onQtyChanged(idx, int.tryParse(val) ?? 0),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: item.rate == 0 ? '' : item.rate.toString(),
                  decoration: const InputDecoration(labelText: 'Rate'),
                  keyboardType: TextInputType.number,
                  onChanged:
                      (val) => onRateChanged(idx, double.tryParse(val) ?? 0),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Item'),
                          content: const Text(
                            'Are you sure you want to delete this item?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    onDeleteItem(idx);
                  }
                },
              ),
            ],
          );
        }),
      ],
    );
  }
}
