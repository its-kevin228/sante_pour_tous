class VitalSign {
  const VitalSign({
    required this.id,
    required this.patientId,
    required this.bloodPressure,
    required this.weight,
    required this.temperature,
    required this.recordedAt,
  });

  final int? id;
  final String patientId;
  final String bloodPressure;
  final double weight;
  final double temperature;
  final DateTime recordedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'blood_pressure': bloodPressure,
      'weight': weight,
      'temperature': temperature,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory VitalSign.fromMap(Map<String, Object?> map) {
    return VitalSign(
      id: map['id'] as int?,
      patientId: map['patient_id'] as String,
      bloodPressure: map['blood_pressure'] as String? ?? '',
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0,
      recordedAt: DateTime.tryParse(map['recorded_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
