import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:royal_invoice/services/pdf_header.dart';
import 'package:royal_invoice/services/pdf_footer.dart';

class InvoicePdfGenerator {
  static Future<Uint8List> generateInvoicePdf({
    required String customerName,
    required String customerAddress,
    required List<Map<String, dynamic>> items,
    required Map<String, String> invoiceDetails,
    required String tagline,
    required Uint8List logoBytes,
    required Map<String, String> businessInfo,
    required PdfPageFormat pageFormat,
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
              pw.Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: QuotePdfFooter(
                  footerH: footerH,
                  businessInfo: businessInfo,
                ),
              ),

              // CONTENT
              pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(
                  48,
                  headerH + 20,
                  40,
                  footerH + 20,
                ),
                child: _buildInvoiceBody(
                  customerName: customerName,
                  customerAddress: customerAddress,
                  items: items,
                  invoiceDetails: invoiceDetails,
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

  static pw.Widget _buildInvoiceBody({
    required String customerName,
    required String customerAddress,
    required List<Map<String, dynamic>> items,
    required Map<String, String> invoiceDetails,
    required pw.Font limelight,
  }) {
    final total = _calculateTotal(items);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: 10),
        pw.Text(
          'INVOICE',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 18),

        // CUSTOMER + DETAILS ROW
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // customer
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Invoice To :-',
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

            // invoice details
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
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
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
            ),
          ],
        ),

        pw.SizedBox(height: 18),

        // ITEMS TABLE (manual vertical lines; total row merged first 3 cols)
        pw.Table(
          // Outer border only (no built-in verticalInside so we can "merge" last row)
          border: const pw.TableBorder(
            top: pw.BorderSide(),
            bottom: pw.BorderSide(),
            left: pw.BorderSide(),
            right: pw.BorderSide(),
            horizontalInside: pw.BorderSide.none,
            verticalInside: pw.BorderSide.none, // ✅ important
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            // HEADER ROW (manual right borders for first 3 cols)
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 1)),
              ),
              children: [
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide(width: 1)),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Description',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide(width: 1)),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Qty',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide(width: 1)),
                  ),
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

            // ITEM ROWS (manual right borders for first 3 cols)
            ...items.map((item) {
              final desc = (item['description'] ?? '').toString();
              final qty = (item['quantity'] ?? '').toString();
              final rate = (item['rate'] ?? '').toString();
              final amount = (item['amount'] ?? '').toString();

              return pw.TableRow(
                children: [
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(right: pw.BorderSide(width: 1)),
                    ),
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(desc),
                  ),
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(right: pw.BorderSide(width: 1)),
                    ),
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(qty, textAlign: pw.TextAlign.center),
                  ),
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(right: pw.BorderSide(width: 1)),
                    ),
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

            // TOTAL ROW (first 3 cols merged visually: no lines between them)
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(width: 1),
                  bottom: pw.BorderSide(width: 1),
                ),
              ),
              children: [
                // Col 1: label
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      'Total Amount',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ),
                // Col 2 empty
                pw.SizedBox(),
                // Col 3 empty
                pw.SizedBox(),

                // Col 4: total with ONLY left border (separator)
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(left: pw.BorderSide(width: 1)),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    total.toStringAsFixed(2),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                      decorationStyle: pw.TextDecorationStyle.double,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        pw.Spacer(),

        // SIGNATURES
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
      ],
    );
  }

  static double _calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(
      0.0,
      (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0),
    );
  }
}