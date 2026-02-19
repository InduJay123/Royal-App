import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QuotePdfHeader extends pw.StatelessWidget {
  QuotePdfHeader({
    required this.headerH,
    required this.logoBytes,
    required this.businessInfo,
    required this.tagline,
  });

  final double headerH;
  final Uint8List logoBytes;
  final Map<String, String> businessInfo;
  final String tagline;

  @override
  pw.Widget build(pw.Context context) {
    return pw.SizedBox(
      height: headerH,
      child: pw.Stack(
        children: [
          pw.Container(color: PdfColors.white),

          // top black bar
          pw.Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: pw.Container(height: 32, color: PdfColors.black),
          ),

          // orange slanted bar (top-right like image)
          pw.Positioned(
            right: 0,
            top: 32,
            child: pw.SizedBox(
              width: 220,
              height: 44,
              child: pw.SvgImage(
                svg: _topRightSlantedBarSvg(
                  width: 220,
                  height: 36,
                  slant: 70,
                  colorHex: '#F3A24B',
                ),
                fit: pw.BoxFit.fill,
              ),
            ),
          ),

          // logo + company name
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(36, 45, 28, 0),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 90,
                  height: 50,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.SizedBox(width: 14),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      (businessInfo['Company Name'] ?? '').toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                         letterSpacing: 1.2
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      tagline.toUpperCase(),
                      style: const pw.TextStyle(fontSize: 10, letterSpacing: 1.6),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(height: 1, width: 250, color: PdfColors.grey800),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // slanted trapezoid like screenshot
  static String _topRightSlantedBarSvg({
    required double width,
    required double height,
    required double slant,
    required String colorHex,
  }) {
    return '''
<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" viewBox="0 0 $width $height" preserveAspectRatio="none">
  <polygon points="$width,0 0,0 $slant,$height $width,$height" fill="$colorHex"/>
</svg>
''';
  }
}