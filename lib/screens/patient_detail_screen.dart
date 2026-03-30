import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';
import '../models/patient.dart';
import '../models/vaccination_record.dart';
import '../models/vital_sign.dart';
import '../services/pdf_export_service.dart';
import 'patient_edit_screen.dart';
import '../theme/app_theme.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({
    required this.patientId,
    super.key,
  });

  final String patientId;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Future<_PatientDetailData?> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  void _refresh() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche patient'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exporter en PDF',
            onPressed: _exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifier',
            onPressed: () async {
              final navigator = Navigator.of(context);
              final data = await _dataFuture;
              if (!mounted || data == null) {
                return;
              }

              final updated = await navigator.push<bool>(
                MaterialPageRoute(
                  builder: (_) => PatientEditScreen(
                    patient: data.patient,
                    vaccination: data.vaccination,
                  ),
                ),
              );

              if (updated == true) {
                _refresh();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Supprimer',
            onPressed: _deletePatient,
          ),
        ],
      ),
      body: FutureBuilder<_PatientDetailData?>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Patient introuvable'));
          }

          final patient = data.patient;
          final latestVital = data.vitalSigns.isNotEmpty ? data.vitalSigns.first : null;
          final vaccination = data.vaccination;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.id, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${patient.lastName} ${patient.firstName}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Âge: ${patient.age} ans | Groupe: ${patient.bloodGroup} | Électrophorèse: ${patient.electrophoresis}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('État clinique', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Allergies: ${patient.allergies.isEmpty ? 'Aucune' : patient.allergies}'),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Dernier traitement: ${patient.lastTreatment.isEmpty ? 'Non renseigné' : patient.lastTreatment}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Constantes vitales',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (latestVital == null)
                        const Text('Aucune mesure enregistrée')
                      else ...[
                        Text('Tension: ${latestVital.bloodPressure} mmHg'),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Poids: ${latestVital.weight} kg'),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Température: ${latestVital.temperature} °C'),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Mesure: ${_formatDateTime(latestVital.recordedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton.icon(
                        onPressed: () => _showAddVitalDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter une mesure'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historique des constantes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (data.vitalSigns.isEmpty)
                        const Text('Aucun historique disponible')
                      else
                        ...data.vitalSigns.map(
                          (vital) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: AppRadii.sm,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDateTime(vital.recordedAt),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Tension ${vital.bloodPressure} | Poids ${vital.weight} kg | Temp ${vital.temperature} °C',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vaccination', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      _vaccineRow('BCG', vaccination?.bcg ?? false),
                      _vaccineRow('DTC / Polio', vaccination?.dtcPolio ?? false),
                      _vaccineRow('Hépatite B', vaccination?.hepatiteB ?? false),
                      _vaccineRow('ROR', vaccination?.ror ?? false),
                      _vaccineRow('Fièvre Jaune', vaccination?.fievreJaune ?? false),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _vaccineRow(String label, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isDone ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _showAddVitalDialog(BuildContext context) async {
    final bloodPressureController = TextEditingController();
    final weightController = TextEditingController();
    final temperatureController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ajouter des constantes'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: bloodPressureController,
                  decoration: const InputDecoration(
                    labelText: 'Tension (ex: 120/80)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tension requise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Poids (kg)'),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Poids invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: temperatureController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Température (°C)'),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Température invalide';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true) {
      bloodPressureController.dispose();
      weightController.dispose();
      temperatureController.dispose();
      return;
    }

    final vital = VitalSign(
      id: null,
      patientId: widget.patientId,
      bloodPressure: bloodPressureController.text.trim(),
      weight: double.parse(weightController.text.trim()),
      temperature: double.parse(temperatureController.text.trim()),
      recordedAt: DateTime.now(),
    );

    await AppDatabase.instance.insertVitalSign(vital);
    bloodPressureController.dispose();
    weightController.dispose();
    temperatureController.dispose();
    _refresh();
  }

  Future<void> _deletePatient() async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la fiche'),
        content: const Text(
          'Cette action supprimera le patient et tout son historique.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await AppDatabase.instance.deletePatient(widget.patientId);

    if (!mounted) {
      return;
    }

    navigator.pop(true);
  }

  Future<void> _exportPdf() async {
    final data = await _dataFuture;

    if (!mounted || data == null) {
      return;
    }

    final path = await PdfExportService.exportPatientRecord(
      patient: data.patient,
      vitalSigns: data.vitalSigns,
      vaccination: data.vaccination,
    );

    if (!mounted) {
      return;
    }

    final fileName = p.basename(path);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF "$fileName" prêt')),
    );

    await _showPdfActions(path, fileName);
  }

  Future<void> _showPdfActions(String path, String fileName) async {
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final rootMessenger = ScaffoldMessenger.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export terminé',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  fileName,
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await OpenFilex.open(path);
                          if (!sheetContext.mounted) {
                            return;
                          }
                          Navigator.of(sheetContext).pop();
                          if (result.type != ResultType.done) {
                            rootMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Impossible d\'ouvrir le PDF sur cet appareil'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Ouvrir'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await SharePlus.instance.share(
                            ShareParams(
                              files: [XFile(path)],
                              text: 'Fiche patient: $fileName',
                            ),
                          );
                          if (!sheetContext.mounted) {
                            return;
                          }
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Partager'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Future<_PatientDetailData?> _loadData() async {
    final db = AppDatabase.instance;
    final patient = await db.getPatientById(widget.patientId);

    if (patient == null) {
      return null;
    }

    final vitalSigns = await db.getVitalSignsForPatient(widget.patientId);
    final vaccination = await db.getVaccinationRecordForPatient(widget.patientId);

    return _PatientDetailData(
      patient: patient,
      vitalSigns: vitalSigns,
      vaccination: vaccination,
    );
  }
}

class _PatientDetailData {
  const _PatientDetailData({
    required this.patient,
    required this.vitalSigns,
    required this.vaccination,
  });

  final Patient patient;
  final List<VitalSign> vitalSigns;
  final VaccinationRecord? vaccination;
}
