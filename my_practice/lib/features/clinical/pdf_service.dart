import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateConsultationSummary({
    required String patientId,
    required Map<String, String> sections,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'SmartHealth Consultation Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text('Patient: $patientId'),
          pw.Text('Generated: ${DateTime.now().toIso8601String()}'),
          pw.SizedBox(height: 16),
          ...sections.entries.map(
            (e) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(e.key, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(e.value.isEmpty ? '—' : e.value),
                pw.SizedBox(height: 8),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: 'https://smarthealth.co.zw/verify/consultation/$patientId',
            width: 80,
            height: 80,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  static Future<void> generatePrescription({
    required String patientId,
    required String medication,
    required String dosage,
    required String practitionerName,
    required String facilityName,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(facilityName, style: pw.TextStyle(fontSize: 16)),
            pw.Text('Prescription'),
            pw.Divider(),
            pw.Text('Patient: $patientId'),
            pw.Text('Medication: $medication'),
            pw.Text('Dosage: $dosage'),
            pw.Spacer(),
            pw.Text('Prescriber: $practitionerName'),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }
}
