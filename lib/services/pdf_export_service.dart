import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/patient.dart';
import '../models/vaccination_record.dart';
import '../models/vital_sign.dart';

class PdfExportService {
  const PdfExportService._();

  static Future<String> exportPatientRecord({
    required Patient patient,
    required List<VitalSign> vitalSigns,
    required VaccinationRecord? vaccination,
  }) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Fiche de suivi medical - Sante Pour Tous',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('ID patient: ${patient.id}'),
          pw.Text('Nom: ${patient.lastName}'),
          pw.Text('Prenom: ${patient.firstName}'),
          pw.Text('Age: ${patient.age} ans'),
          pw.Text('Groupe sanguin: ${patient.bloodGroup}'),
          pw.Text('Electrophorese: ${patient.electrophoresis}'),
          pw.SizedBox(height: 12),
          pw.Text(
            'Etat clinique',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('Allergies: ${patient.allergies.isEmpty ? 'Aucune' : patient.allergies}'),
          pw.Text(
            'Dernier traitement: ${patient.lastTreatment.isEmpty ? 'Non renseigne' : patient.lastTreatment}',
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Vaccination',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Bullet(text: 'BCG: ${_yesNo(vaccination?.bcg ?? false)}'),
          pw.Bullet(text: 'DTC / Polio: ${_yesNo(vaccination?.dtcPolio ?? false)}'),
          pw.Bullet(text: 'Hepatite B: ${_yesNo(vaccination?.hepatiteB ?? false)}'),
          pw.Bullet(text: 'ROR: ${_yesNo(vaccination?.ror ?? false)}'),
          pw.Bullet(text: 'Fievre Jaune: ${_yesNo(vaccination?.fievreJaune ?? false)}'),
          pw.SizedBox(height: 12),
          pw.Text(
            'Historique des constantes vitales',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          if (vitalSigns.isEmpty)
            pw.Text('Aucune mesure enregistree')
          else
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Tension', 'Poids (kg)', 'Temperature (C)'],
              data: vitalSigns
                  .map(
                    (vital) => [
                      _formatDateTime(vital.recordedAt),
                      vital.bloodPressure,
                      vital.weight.toString(),
                      vital.temperature.toString(),
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
            ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeId = patient.id.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final fileName = 'fiche_${safeId}_$timestamp.pdf';
    final filePath = p.join(directory.path, fileName);
    final file = File(filePath);

    await file.writeAsBytes(await document.save());
    return file.path;
  }

  static String _yesNo(bool value) => value ? 'Oui' : 'Non';

  static String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
