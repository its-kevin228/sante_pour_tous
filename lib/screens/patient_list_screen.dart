import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  late Future<List<Patient>> _patientsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedBloodGroup;
  String? _selectedElectrophoresis;

  @override
  void initState() {
    super.initState();
    _patientsFuture = AppDatabase.instance.getPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _patientsFuture = AppDatabase.instance.getPatients();
    });
  }

  Future<void> _openCreateForm() async {
    final id = await AppDatabase.instance.generateNextPatientId();
    if (!mounted) {
      return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PatientFormScreen(generatedId: id),
      ),
    );

    if (created == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Text('Santé Pour Tous'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: FutureBuilder<List<Patient>>(
        future: _patientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final patients = snapshot.data ?? [];
          final normalizedQuery = _searchQuery.trim().toLowerCase();
            final filteredPatients = patients.where((patient) {
            final searchable =
              '${patient.id} ${patient.lastName} ${patient.firstName}'.toLowerCase();
            final matchesSearch =
              normalizedQuery.isEmpty || searchable.contains(normalizedQuery);
            final matchesBlood = _selectedBloodGroup == null ||
              patient.bloodGroup == _selectedBloodGroup;
            final matchesElectro = _selectedElectrophoresis == null ||
              patient.electrophoresis == _selectedElectrophoresis;
            return matchesSearch && matchesBlood && matchesElectro;
            }).toList();

          if (patients.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Aucun patient enregistré pour le moment.\nAppuie sur + pour créer la première fiche.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par ID, nom ou prénom',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedBloodGroup,
                                decoration: const InputDecoration(
                                  labelText: 'Filtre groupe sanguin',
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Tous'),
                                  ),
                                  ...bloodGroups.map(
                                    (group) => DropdownMenuItem(
                                      value: group,
                                      child: Text(group),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedBloodGroup = value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedElectrophoresis,
                                decoration: const InputDecoration(
                                  labelText: 'Filtre électrophorèse',
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Toutes'),
                                  ),
                                  ...electrophoresisTypes.map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedElectrophoresis = value);
                                },
                              ),
                            ),
                          ],
                        ),
                        if (_selectedBloodGroup != null ||
                            _selectedElectrophoresis != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedBloodGroup = null;
                                  _selectedElectrophoresis = null;
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Réinitialiser filtres'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredPatients.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'Aucun résultat pour "$normalizedQuery"',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemBuilder: (context, index) {
                          final patient = filteredPatients[index];
                          return Card(
                            child: ListTile(
                              title: Text('${patient.lastName} ${patient.firstName}'),
                              subtitle: Text(
                                '${patient.id} • ${patient.age} ans • ${patient.bloodGroup}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async {
                                final changed = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PatientDetailScreen(patientId: patient.id),
                                  ),
                                );
                                if (changed == true) {
                                  _refresh();
                                }
                              },
                            ),
                          );
                        },
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: AppSpacing.xs),
                        itemCount: filteredPatients.length,
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateForm,
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.brandText,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau patient'),
      ),
    );
  }
}
