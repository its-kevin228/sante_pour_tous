class Patient {
  const Patient({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.age,
    required this.bloodGroup,
    required this.electrophoresis,
    required this.allergies,
    required this.lastTreatment,
    required this.createdAt,
  });

  final String id;
  final String lastName;
  final String firstName;
  final int age;
  final String bloodGroup;
  final String electrophoresis;
  final String allergies;
  final String lastTreatment;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'last_name': lastName,
      'first_name': firstName,
      'age': age,
      'blood_group': bloodGroup,
      'electrophoresis': electrophoresis,
      'allergies': allergies,
      'last_treatment': lastTreatment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, Object?> map) {
    return Patient(
      id: map['id'] as String,
      lastName: map['last_name'] as String? ?? '',
      firstName: map['first_name'] as String? ?? '',
      age: map['age'] as int? ?? 0,
      bloodGroup: map['blood_group'] as String? ?? '',
      electrophoresis: map['electrophoresis'] as String? ?? '',
      allergies: map['allergies'] as String? ?? '',
      lastTreatment: map['last_treatment'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

const List<String> bloodGroups = [
  'A+',
  'A-',
  'B+',
  'B-',
  'O+',
  'O-',
  'AB+',
  'AB-',
];

const List<String> electrophoresisTypes = [
  'AA',
  'AS',
  'AC',
  'SS',
  'SC',
  'Autre',
];
