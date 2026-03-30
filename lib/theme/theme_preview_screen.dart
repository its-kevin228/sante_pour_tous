import 'package:flutter/material.dart';

import 'app_theme.dart';

class ThemePreviewScreen extends StatefulWidget {
  const ThemePreviewScreen({super.key});

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  bool bcg = true;
  bool dtcPolio = false;
  bool hepatiteB = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Santé Pour Tous')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('Charte Graphique', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Base visuelle utilisée pour les prochains écrans du dossier patient.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Identité patient', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  const TextField(decoration: InputDecoration(labelText: 'Nom', hintText: 'AGBAM')),
                  const SizedBox(height: AppSpacing.sm),
                  const TextField(decoration: InputDecoration(labelText: 'Prénom', hintText: 'Hervé')),
                  const SizedBox(height: AppSpacing.sm),
                  const TextField(decoration: InputDecoration(labelText: 'Âge', hintText: '24')),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Enregistrer la fiche'),
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
                  const SizedBox(height: AppSpacing.xs),
                  _VaccineItem(
                    label: 'BCG',
                    value: bcg,
                    onChanged: (value) => setState(() => bcg = value ?? false),
                  ),
                  _VaccineItem(
                    label: 'DTC / Polio',
                    value: dtcPolio,
                    onChanged: (value) => setState(() => dtcPolio = value ?? false),
                  ),
                  _VaccineItem(
                    label: 'Hépatite B',
                    value: hepatiteB,
                    onChanged: (value) => setState(() => hepatiteB = value ?? false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccineItem extends StatelessWidget {
  const _VaccineItem({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
