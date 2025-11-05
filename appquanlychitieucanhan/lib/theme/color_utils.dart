import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' as pdf;

Color colorFromHex(String hex) {
  var s = hex.replaceAll('#', '');
  if (s.length == 6) s = 'FF$s';
  return Color(int.parse(s, radix: 16));
}

pdf.PdfColor pdfColorFromHex(String hex) {
  final c = colorFromHex(hex);
  return pdf.PdfColor.fromInt(
      (c.alpha << 24) | (c.red << 16) | (c.green << 8) | c.blue);
}

LinearGradient gradientFromHex(String hex, {double a1 = .20, double a2 = .08}) {
  final base = colorFromHex(hex);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [base.withOpacity(a1), base.withOpacity(a2)],
  );
}

Color amountColor(bool isIncome) =>
    isIncome ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);

const LinearGradient statsBackgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.7, 1.0],
  colors: [
    Color(0xFF3F51B5),
    Color(0xFF7C4DFF),
    Color(0xCCFF4D6D),
  ],
);
