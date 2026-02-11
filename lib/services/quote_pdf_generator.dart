import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

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
    final customFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Limelight-Regular.ttf'));


    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(38),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (logoBytes != null)
                    pw.Container(
                      width: 240,
                      height: 130,
                      child: pw.Image(pw.MemoryImage(logoBytes)),
                    ),
                  pw.SizedBox(width: 26),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          businessInfo['Company Name'] ?? '',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        // Split address into multiple lines
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: (businessInfo['Address'] ?? '').split(',').map((line) {
                            return pw.Text(line.trim(), style: pw.TextStyle(fontSize: 12));
                          }).toList(),
                        ),
                        pw.SizedBox(height: 4),
                        // Print other details
                        ...businessInfo.entries
                            .where((e) => e.key != 'Company Name' && e.key != 'Address')
                            .map(
                              (e) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 4),
                            child: pw.RichText(
                              text: pw.TextSpan(
                                children: [
                                  pw.TextSpan(
                                    text: '${e.key}: ',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  pw.TextSpan(
                                    text: e.value,
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).toList(),
                      ],
                    ),
                  ),
                ],
              ),


              pw.SizedBox(height: 18),
              pw.Text('QUOTATION', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 18),
              pw.Text('Quotation To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Customer info column
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          customerName,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),

                        ...customerAddress
                            .split('\n')
                            .map((line) => pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 4),
                          child: pw.Text(line),
                        ))
                            .toList(),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 90), // small spacer instead of large fixed width
                  // Invoice details table
                  pw.Expanded(
                    flex: 1,
                    child: pw.Table(
                      columnWidths: {
                        0: pw.FixedColumnWidth(110),
                        1: pw.FlexColumnWidth(),
                      },
                      children: invoiceDetails.entries.map((e) {
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4),
                              child: pw.Text(
                                e.key,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4),
                              child: pw.Text(e.value),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),


              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'QUOTATION FOR ',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Text(
                    quotationFor.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.SizedBox(height: 12),
              pw.Table(
                border: const pw.TableBorder(
                  top: pw.BorderSide(),
                  bottom: pw.BorderSide(),
                  left: pw.BorderSide(),
                  right: pw.BorderSide(),
                  horizontalInside: pw.BorderSide.none,
                  verticalInside: pw.BorderSide.none,
                ),
                columnWidths: {
                  0: pw.FlexColumnWidth(4),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                },
                children: [
                  // Header Row with full horizontal and vertical borders
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(),
                        bottom: pw.BorderSide(),
                      ),
                    ),
                    children: [
                      pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide(width: 0.5)),
                        ),
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      ),
                      pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide(width: 0.5)),
                        ),
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      ),
                      pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide(width: 1)),
                        ),
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Unit Price(LKR)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Total Price (LKR)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      ),
                    ],
                  ),

                  // Item Rows with only vertical borders
                  ...items.map(
                        (item) => pw.TableRow(
                      children: [
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(right: pw.BorderSide(width: 0.5)),
                          ),
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item['description'].toString()),
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(right: pw.BorderSide(width: 0.5)),
                          ),
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item['quantity'].toString(), textAlign: pw.TextAlign.center),
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(right: pw.BorderSide(width: 1)),
                          ),
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            (item['rate'] as double).toStringAsFixed(2), // 2 decimal places
                            textAlign: pw.TextAlign.right,
                          ),),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            (item['amount'] as double).toStringAsFixed(2), // 2 decimal places
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Total Row with full horizontal and vertical borders

                ],
              ),

              pw.SizedBox(height: 18),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 80), // adjust 20 to desired start margin
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text('Approved by,', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 210),
                    pw.Text('Received by,', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 80),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text('.............................', style: pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(width: 210),
                    pw.Text('.............................', style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  tagline,
                  style: pw.TextStyle(
                    font: customFont,
                    fontSize: 12,
                  ),
                ),
              ),

            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static double _calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0, (sum, item) => sum + (item['amount'] as num).toDouble());
  }
}