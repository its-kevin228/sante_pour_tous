class VaccinationRecord {
  const VaccinationRecord({
    required this.patientId,
    required this.bcg,
    required this.dtcPolio,
    required this.hepatiteB,
    required this.ror,
    required this.fievreJaune,
    required this.updatedAt,
  });

  final String patientId;
  final bool bcg;
  final bool dtcPolio;
  final bool hepatiteB;
  final bool ror;
  final bool fievreJaune;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'patient_id': patientId,
      'bcg': bcg ? 1 : 0,
      'dtc_polio': dtcPolio ? 1 : 0,
      'hepatite_b': hepatiteB ? 1 : 0,
      'ror': ror ? 1 : 0,
      'fievre_jaune': fievreJaune ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory VaccinationRecord.fromMap(Map<String, Object?> map) {
    return VaccinationRecord(
      patientId: map['patient_id'] as String,
      bcg: (map['bcg'] as int? ?? 0) == 1,
      dtcPolio: (map['dtc_polio'] as int? ?? 0) == 1,
      hepatiteB: (map['hepatite_b'] as int? ?? 0) == 1,
      ror: (map['ror'] as int? ?? 0) == 1,
      fievreJaune: (map['fievre_jaune'] as int? ?? 0) == 1,
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  VaccinationRecord copyWith({
    bool? bcg,
    bool? dtcPolio,
    bool? hepatiteB,
    bool? ror,
    bool? fievreJaune,
  }) {
    return VaccinationRecord(
      patientId: patientId,
      bcg: bcg ?? this.bcg,
      dtcPolio: dtcPolio ?? this.dtcPolio,
      hepatiteB: hepatiteB ?? this.hepatiteB,
      ror: ror ?? this.ror,
      fievreJaune: fievreJaune ?? this.fievreJaune,
      updatedAt: DateTime.now(),
    );
  }
}
