import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../models/patient.dart';
import '../models/vaccination_record.dart';
import '../theme/app_theme.dart';

class PatientEditScreen extends StatefulWidget {
  const PatientEditScreen({
    required this.patient,
    required this.vaccination,
    super.key,
  });

  final Patient patient;
  final VaccinationRecord? vaccination;

  @override
  State<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends State<PatientEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _lastNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _lastTreatmentController;

  late String _selectedBloodGroup;
  late String _selectedElectrophoresis;

  late bool _bcg;
  late bool _dtcPolio;
  late bool _hepatiteB;
  late bool _ror;
  late bool _fievreJaune;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final patient = widget.patient;
    final vax = widget.vaccination;

    _lastNameController = TextEditingController(text: patient.lastName);
    _firstNameController = TextEditingController(text: patient.firstName);
    _ageController = TextEditingController(text: patient.age.toString());
    _allergiesController = TextEditingController(text: patient.allergies);
    _lastTreatmentController = TextEditingController(text: patient.lastTreatment);

    _selectedBloodGroup = patient.bloodGroup;
    _selectedElectrophoresis = patient.electrophoresis;

    _bcg = vax?.bcg ?? false;
    _dtcPolio = vax?.dtcPolio ?? false;
    _hepatiteB = vax?.hepatiteB ?? false;
    _ror = vax?.ror ?? false;
    _fievreJaune = vax?.fievreJaune ?? false;
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _ageController.dispose();
    _allergiesController.dispose();
    _lastTreatmentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final updatedPatient = widget.patient.copyWith(
      lastName: _lastNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      bloodGroup: _selectedBloodGroup,
      electrophoresis: _selectedElectrophoresis,
      allergies: _allergiesController.text.trim(),
      lastTreatment: _lastTreatmentController.text.trim(),
    );

    final vaccination = VaccinationRecord(
      patientId: widget.patient.id,
      bcg: _bcg,
      dtcPolio: _dtcPolio,
      hepatiteB: _hepatiteB,
      ror: _ror,
      fievreJaune: _fievreJaune,
      updatedAt: DateTime.now(),
    );

    final db = AppDatabase.instance;
    await db.updatePatient(updatedPatient);
    await db.upsertVaccinationRecord(vaccination);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier patient')),
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
                    Text(widget.patient.id, style: Theme.of(context).textTheme.bodySmall),
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
              child: Text(_isSaving ? 'Enregistrement...' : 'Mettre à jour'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
