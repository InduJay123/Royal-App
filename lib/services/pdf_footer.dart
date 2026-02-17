import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QuotePdfFooter extends pw.StatelessWidget {
  QuotePdfFooter({
    required this.footerH,
    required this.businessInfo,
  });

  final double footerH;
  final Map<String, String> businessInfo;

  @override
  pw.Widget build(pw.Context context) {
    return pw.SizedBox(
      height: footerH,
      child: pw.Stack(
        children: [
          pw.Container(color: PdfColors.white),

          // bottom black bar
          pw.Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: pw.Container(height: 20, color: PdfColors.black),
          ),

          // bottom-left orange trapezoid like screenshot
          pw.Positioned(
            left: 0,
            bottom: 0,
            child: pw.SizedBox(
              width: 150,
              height: 45,
              child: pw.SvgImage(
                svg: _bottomLeftTrapezoidSvg(
                  width: 150,
                  height: 16,
                  topFlat: 55,
                  colorHex: '#F3A24B',
                ),
                fit: pw.BoxFit.fill,
              ),
            ),
          ),

          // top line above footer
          pw.Positioned(
            left: 80,
            right: 60,
            top: 10,
            child: pw.Container(height: 1, color: PdfColors.grey800),
          ),

          // footer info
          pw.Positioned(
            left: 45,
            right: 45,
            top: 24,
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      "Email:   ${businessInfo['Email'] ?? 'royalmachinary95@gmail.com'}",
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.SizedBox(width: 24),
                    pw.Text(
                      "Tel:  ${businessInfo['Tel'] ?? '+94 70 288 3737'}",
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  "Address:   ${businessInfo['Address'] ?? ''}",
                  style: const pw.TextStyle(fontSize: 9),    
                  maxLines: 1         
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _bottomLeftTrapezoidSvg({
    required double width,
    required double height,
    required double topFlat,
    required String colorHex,
  }) {
    return '''
<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" viewBox="0 0 $width $height" preserveAspectRatio="none">
  <polygon points="0,$height 0,0 $topFlat,0 $width,$height" fill="$colorHex"/>
</svg>
''';
  }
}