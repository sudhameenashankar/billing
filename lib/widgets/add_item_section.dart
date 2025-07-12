import 'package:billing/utility/general_utility.dart';
import 'package:flutter/material.dart';

class AddItemSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController qtyController;
  final TextEditingController rateController;
  final VoidCallback onAddItem;

  const AddItemSection({
    super.key,
    required this.nameController,
    required this.qtyController,
    required this.rateController,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Item Name'),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [UpperCaseTextFormatter()],
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: TextFormField(
            controller: qtyController,
            decoration: const InputDecoration(labelText: 'Qty'),
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: TextFormField(
            controller: rateController,
            decoration: const InputDecoration(labelText: 'Rate'),
            keyboardType: TextInputType.number,
          ),
        ),
        IconButton(icon: Icon(Icons.add), onPressed: onAddItem),
      ],
    );
  }
}
