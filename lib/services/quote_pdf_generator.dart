import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:royal_invoice/services/pdf_header.dart';
import 'package:royal_invoice/services/pdf_footer.dart';

class QuotePdfGenerator {
  static Future<Uint8List> generateInvoicePdf({
    required String customerName,
    required String customerAddress,
    required List<Map<String, dynamic>> items,
    required Map<String, String> invoiceDetails,
    required String tagline,
    required Uint8List logoBytes,
    required Map<String, String> businessInfo,
    required PdfPageFormat pageFormat,
    required String quotationFor,
  }) async {
    final pdf = pw.Document();

    final limelight =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Limelight-Regular.ttf'));

    const headerH = 95.0;
    const footerH = 90.0;

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Stack(
            children: [
              // HEADER 
              // =========================
              pw.Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: QuotePdfHeader(
                  headerH: headerH,
                  logoBytes: logoBytes,
                  businessInfo: businessInfo,
                  tagline: tagline,
                ),
              ),

              // FOOTER 
              // =========================
              pw.Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: QuotePdfFooter(
                  footerH: footerH,
                  businessInfo: businessInfo,
                ),
              ),

              // =========================
              // CONTENT
              // =========================
              pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(
                  48,
                  headerH + 20,
                  40,
                  footerH + 20,
                ),
                child: _buildQuotationBody(
                  customerName: customerName,
                  customerAddress: customerAddress,
                  items: items,
                  invoiceDetails: invoiceDetails,
                  quotationFor: quotationFor,
                  limelight: limelight,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ---------- BODY ----------
  static pw.Widget _buildQuotationBody({
    required String customerName,
    required String customerAddress,
    required List<Map<String, dynamic>> items,
    required Map<String, String> invoiceDetails,
    required String quotationFor,
    required pw.Font limelight,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: 10),
        pw.Text(
          'QUOTATION',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 18),

        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Quotation To :-',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    customerName,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  ...customerAddress
                      .split('\n')
                      .where((e) => e.trim().isNotEmpty)
                      .map((e) => pw.Text(e))
                      .toList(),
                ],
              ),
            ),
            pw.SizedBox(width: 30),
            pw.Expanded(
              child: pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(110),
                  1: const pw.FlexColumnWidth(),
                },
                children: invoiceDetails.entries.map((e) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 5),
                        child: pw.Text(
                          e.key,
                          style:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 5),
                        child: pw.Text(e.value),
                      ),
                    ],
                  );
                }).toList(),
              ),
            )
          ],
        ),

        pw.SizedBox(height: 16),
        pw.Center(
          child: pw.Text(
            'QUOTATION FOR ${quotationFor.toUpperCase()}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 14),

        // Items table
        pw.Table(
          border: const pw.TableBorder(
            top: pw.BorderSide(),
            bottom: pw.BorderSide(),
            left: pw.BorderSide(),
            right: pw.BorderSide(),
            verticalInside: pw.BorderSide(),   // column lines
            horizontalInside: pw.BorderSide.none, 
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 1),
              ),
            ),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Description',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Qty',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Unit Price',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Total',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...items.map((item) {
              final desc = (item['description'] ?? '').toString();
              final qty = (item['quantity'] ?? '').toString();
              final rate = (item['rate'] ?? '').toString();
              final amount = (item['amount'] ?? '').toString();

              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(desc),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(qty, textAlign: pw.TextAlign.center),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(rate, textAlign: pw.TextAlign.right),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(amount, textAlign: pw.TextAlign.right),
                  ),
                ],
              );
            }).toList(),
          ],
        ),

        pw.Spacer(),

        // Signatures
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              children: [
                pw.Text(
                  'Approved by,',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Text(
                  '.............................',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
            pw.Column(
              children: [
                pw.Text(
                  'Received by,',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Text(
                  '.............................',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
          ],
        ),

        // pw.SizedBox(height: 18),
        // pw.Center(
        //   child: pw.Text(
        //     'ALWAYS DEDICATED AND DEVOTED.',
        //     style: pw.TextStyle(font: limelight, fontSize: 12),
        //   ),
        // ),
      ],
    );
  }
}