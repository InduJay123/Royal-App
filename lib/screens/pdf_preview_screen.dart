import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../services/pdf_generator.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String clientName;
  final String clientAddress;
  final String invoiceNo;
  final String poNumber;
  final DateTime? invoiceDate;
  final List<Map<String, dynamic>> items;
  final Map<String, String> businessInfo;
  final String tagline;
  const PdfPreviewScreen({
    super.key,
    required this.clientName,
    required this.clientAddress,
    required this.invoiceNo,
    required this.poNumber,
    this.invoiceDate,
    required this.items,
    required this.businessInfo,
    required this.tagline,
  });

  Future<Uint8List> _loadLogoBytes(String path) async {
    final bytes = await rootBundle.load(path);
    return bytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoice Preview")),
      body: FutureBuilder<Uint8List>(
        future: _loadLogoBytes('assets/logo.png'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading logo: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Logo not found'));
          }

          final logoBytes = snapshot.data!;


          final invoiceDetails = {
            "Date": invoiceDate != null ? invoiceDate!.toString().split(' ')[0] : "",
            "Invoice No": invoiceNo,
            "Delivery Date": invoiceDate != null ? invoiceDate!.toString().split(' ')[0] : "",
            "Business Reg No": "X/25 109522",
            "PO Number": poNumber,
          }; 

          return PdfPreview(
            canChangePageFormat: false,
            canChangeOrientation: false,
            allowPrinting: true,
            allowSharing: true,
            useActions: true,
            build: (format) {
              return PdfGenerator.generateInvoicePdf(
                customerName: clientName,
                customerAddress: clientAddress,
                items: items,
                invoiceDetails: invoiceDetails,
                tagline: "ALWAYS DEDICATED AND DEVOTED",
                logoBytes: logoBytes,
                businessInfo: businessInfo,
                pageFormat: format,
              );
            },
          );
        },
      ),
    );
  }
}
