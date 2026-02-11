import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../services/pdf_generator.dart';
import '../services/quote_pdf_generator.dart';

class QuotePreview extends StatelessWidget {
  final String clientName;
  final String clientAddress;
  final String quotationeNo;
  final String quotationFor;
  final DateTime? quotationDate;
  final List<Map<String, dynamic>> items;
  final Map<String, String> businessInfo;
  final String tagline;
  const QuotePreview({
    super.key,
    required this.clientName,
    required this.clientAddress,
    required this.quotationeNo,
    required this.quotationFor,
    this.quotationDate,
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
      appBar: AppBar(title: const Text("Quotation Preview")),
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
            "Date": quotationDate != null ? quotationDate!.toString().split(' ')[0] : "",
            "Quotation No": quotationeNo,
            "Business Reg No": "X/25 109522"
          };


          return PdfPreview(
            canChangePageFormat: false,
            canChangeOrientation: false,
            allowPrinting: true,
            allowSharing: true,
            useActions: true,
            build: (format) {
              return QuotePdfGenerator.generateInvoicePdf(
                customerName: clientName,
                customerAddress: clientAddress,
                items: items,
                invoiceDetails: invoiceDetails,
                quotationFor: quotationFor,
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
