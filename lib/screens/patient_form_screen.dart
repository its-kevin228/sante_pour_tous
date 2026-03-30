import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../models/patient.dart';
import '../models/vaccination_record.dart';
import '../models/vital_sign.dart';
import '../theme/app_theme.dart';

class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({
    required this.generatedId,
    super.key,
  });

  final String generatedId;

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _lastTreatmentController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();

  String _selectedBloodGroup = bloodGroups.first;
  String _selectedElectrophoresis = electrophoresisTypes.first;

  bool _bcg = false;
  bool _dtcPolio = false;
  bool _hepatiteB = false;
  bool _ror = false;
  bool _fievreJaune = false;

  bool _isSaving = false;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _ageController.dispose();
    _allergiesController.dispose();
    _lastTreatmentController.dispose();
    _bloodPressureController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final patient = Patient(
      id: widget.generatedId,
      lastName: _lastNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      bloodGroup: _selectedBloodGroup,
      electrophoresis: _selectedElectrophoresis,
      allergies: _allergiesController.text.trim(),
      lastTreatment: _lastTreatmentController.text.trim(),
      createdAt: DateTime.now(),
    );

    final vitalSign = VitalSign(
      id: null,
      patientId: patient.id,
      bloodPressure: _bloodPressureController.text.trim(),
      weight: double.parse(_weightController.text.trim()),
      temperature: double.parse(_temperatureController.text.trim()),
      recordedAt: DateTime.now(),
    );

    final vaccination = VaccinationRecord(
      patientId: patient.id,
      bcg: _bcg,
      dtcPolio: _dtcPolio,
      hepatiteB: _hepatiteB,
      ror: _ror,
      fievreJaune: _fievreJaune,
      updatedAt: DateTime.now(),
    );

    final db = AppDatabase.instance;
    await db.insertPatient(patient);
    await db.insertVitalSign(vitalSign);
    await db.upsertVaccinationRecord(vaccination);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle fiche patient')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID patient', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(widget.generatedId, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Nom requis' : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Prénom requis'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Âge'),
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Âge invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBloodGroup,
                      decoration: const InputDecoration(labelText: 'Groupe sanguin'),
                      items: bloodGroups
                          .map((group) => DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              ))
                          .toList(),
                      onChanged: (value) => setState(
                        () => _selectedBloodGroup = value ?? bloodGroups.first,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedElectrophoresis,
                      decoration: const InputDecoration(labelText: 'Électrophorèse'),
                      items: electrophoresisTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) => setState(
                        () => _selectedElectrophoresis =
                            value ?? electrophoresisTypes.first,
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
                    Text('État clinique', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _allergiesController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Allergies'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _lastTreatmentController,
                      maxLines: 2,
                      decoration:
                          const InputDecoration(labelText: 'Dernier traitement'),
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
                      'Constantes vitales du jour',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _bloodPressureController,
                      decoration:
                          const InputDecoration(labelText: 'Tension (ex: 120/80)'),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Tension requise'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _weightController,
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
                      controller: _temperatureController,
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
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carnet de vaccination',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    CheckboxListTile(
                      value: _bcg,
                      onChanged: (value) => setState(() => _bcg = value ?? false),
                      title: const Text('BCG'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _dtcPolio,
                      onChanged: (value) =>
                          setState(() => _dtcPolio = value ?? false),
                      title: const Text('DTC / Polio'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _hepatiteB,
                      onChanged: (value) =>
                          setState(() => _hepatiteB = value ?? false),
                      title: const Text('Hépatite B'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _ror,
                      onChanged: (value) => setState(() => _ror = value ?? false),
                      title: const Text('ROR'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _fievreJaune,
                      onChanged: (value) =>
                          setState(() => _fievreJaune = value ?? false),
                      title: const Text('Fièvre Jaune'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: Text(_isSaving ? 'Enregistrement...' : 'Enregistrer'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
