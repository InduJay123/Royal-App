import 'package:flutter/material.dart';
import 'package:royal_invoice/screens/quote_preview.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:royal_invoice/screens/settings_screen.dart';
import 'pdf_preview_screen.dart';

class QuotationFormScreen extends StatefulWidget {
  const QuotationFormScreen({super.key});

  @override
  State<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends State<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientAddressController = TextEditingController();
  final TextEditingController _quotationNoController = TextEditingController();
  final TextEditingController _quotationForController = TextEditingController();

  DateTime? _quotationDate;

  List<Map<String, dynamic>> _items = [
    {'name': '', 'qty': 1, 'rate': 0.0, 'amount': 0.0},
  ];

  void _addItem() {
    setState(() {
      _items.add({'name': '', 'qty': 1, 'rate': 0.0, 'amount': 0.0});
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateAmount(int index) {
    final item = _items[index];
    final qty = item['qty'] ?? 0;
    final rate = item['rate'] ?? 0.0;
    setState(() {
      _items[index]['amount'] = qty * rate;
    });
  }

  /// Loads business info from SharedPreferences, uses defaults if none saved
  Future<Map<String, String>> _loadBusinessInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final defaultInfo = {
      'Company Name': 'Royal Machinar & Spare parts',
      'Address': 'No:16, Old Farm Road, Galmaduwa, Hingurana, Ampara',
      'Email': 'Royalmachinary95@gmail.com',
      'Tel': '+94 70 288 3737',

    };

    return {
      'Company Name': prefs.getString('companyName')?.trim().isNotEmpty == true
          ? prefs.getString('companyName')!
          : defaultInfo['Company Name']!,
      'Address': prefs.getString('address')?.trim().isNotEmpty == true
          ? prefs.getString('address')!
          : defaultInfo['Address']!,
      'Email': prefs.getString('email')?.trim().isNotEmpty == true
          ? prefs.getString('email')!
          : defaultInfo['Email']!,
      'Tel': prefs.getString('phone')?.trim().isNotEmpty == true
          ? prefs.getString('phone')!
          : defaultInfo['Phone']!,

    };
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final businessInfo = await _loadBusinessInfo();

      final formattedItems = _items.map((item) => {
        'description': item['name'],
        'quantity': item['qty'],
        'rate': item['rate'],
        'amount': item['amount'],
      }).toList();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuotePreview(
              clientName: _clientNameController.text,
              clientAddress: _clientAddressController.text,
              quotationeNo: _quotationNoController.text,
              quotationFor: _quotationForController.text,
              quotationDate: _quotationDate,
              items: formattedItems,
              businessInfo: businessInfo,
              tagline: "ALWAYS DEDICATED AND DEVOTED"// Pass loaded business info here
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation Form'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Business Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(labelText: 'Client Name'),
                validator: (value) =>
                value!.isEmpty ? 'Enter client name' : null,
              ),
              TextFormField(
                controller: _clientAddressController,
                decoration: const InputDecoration(labelText: 'Client Address'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _quotationNoController,
                decoration: const InputDecoration(labelText: 'Quotation No'),
                validator: (value) =>
                value!.isEmpty ? 'Enter Quotation No' : null,
              ),
              TextFormField(
                controller: _quotationForController,
                decoration: const InputDecoration(labelText: 'Quotation For'),
                validator: (value) =>
                value!.isEmpty ? 'Enter Quotation No' : null,
              ),

              const SizedBox(height: 12),
              Text("Quotation Date: ${_quotationDate != null ? _quotationDate!.toLocal().toString().split(' ')[0] : ""}"),

              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _quotationDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _quotationDate = picked;
                    });
                  }
                },
                child: const Text('Select Date'),
              ),
              const Divider(),
              const Text('Items:'),
              ..._items.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> item = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: item['name'],
                          decoration:
                          const InputDecoration(labelText: 'Item Name'),
                          onChanged: (value) => _items[index]['name'] = value,
                          validator: (value) =>
                          value!.isEmpty ? 'Enter item name' : null,
                        ),
                        TextFormField(
                          initialValue: item['qty'].toString(),
                          decoration:
                          const InputDecoration(labelText: 'Quantity'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _items[index]['qty'] = int.tryParse(value) ?? 0;
                            _updateAmount(index);
                          },
                        ),
                        TextFormField(
                          initialValue: item['rate'].toStringAsFixed(2),
                          decoration: const InputDecoration(labelText: 'Rate'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _items[index]['rate'] = double.tryParse(value) ?? 0.00;
                            _updateAmount(index);
                          },
                        ),
                        Text("Amount: ${item['amount'].toStringAsFixed(2)}"),
                        if (_items.length > 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => _removeItem(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              }).toList(),
              ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Generate Quotation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
