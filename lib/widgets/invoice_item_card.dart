import 'package:flutter/material.dart';
import '../models/invoice_item.dart';

class InvoiceItemCard extends StatelessWidget {
  final InvoiceItem item;
  final int index;
  final VoidCallback onRemove;
  final Function(String, int) onUpdate;

  const InvoiceItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              initialValue: item.description,
              decoration: const InputDecoration(labelText: "Description"),
              onChanged: (value) => onUpdate(value, 0),
            ),
            TextFormField(
              initialValue: item.quantity.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
              onChanged: (value) => onUpdate(value, 1),
            ),
            TextFormField(
              initialValue: item.unitPrice.toStringAsFixed(2),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Unit Price (LKR)"),
              onChanged: (value) => onUpdate(value, 2),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
