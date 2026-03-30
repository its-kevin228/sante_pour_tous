import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/patient.dart';
import '../models/vaccination_record.dart';
import '../models/vital_sign.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _databaseName = 'sante_pour_tous.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        last_name TEXT NOT NULL,
        first_name TEXT NOT NULL,
        age INTEGER NOT NULL,
        blood_group TEXT NOT NULL,
        electrophoresis TEXT NOT NULL,
        allergies TEXT NOT NULL,
        last_treatment TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE vital_signs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        blood_pressure TEXT NOT NULL,
        weight REAL NOT NULL,
        temperature REAL NOT NULL,
        recorded_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE vaccination_records (
        patient_id TEXT PRIMARY KEY,
        bcg INTEGER NOT NULL,
        dtc_polio INTEGER NOT NULL,
        hepatite_b INTEGER NOT NULL,
        ror INTEGER NOT NULL,
        fievre_jaune INTEGER NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<String> generateNextPatientId() async {
    final db = await database;
    final result = await db.query(
      'patients',
      columns: ['id'],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return '#AGB-001';
    }

    final lastId = result.first['id'] as String;
    final number = int.tryParse(lastId.replaceAll('#AGB-', '')) ?? 0;
    final next = number + 1;
    return '#AGB-${next.toString().padLeft(3, '0')}';
  }

  Future<void> insertPatient(Patient patient) async {
    final db = await database;
    await db.insert('patients', patient.toMap());
  }

  Future<void> updatePatient(Patient patient) async {
    final db = await database;
    await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<void> deletePatient(String patientId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'vital_signs',
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );
      await txn.delete(
        'vaccination_records',
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );
      await txn.delete(
        'patients',
        where: 'id = ?',
        whereArgs: [patientId],
      );
    });
  }

  Future<List<Patient>> getPatients() async {
    final db = await database;
    final result = await db.query('patients', orderBy: 'created_at DESC');
    return result.map(Patient.fromMap).toList();
  }

  Future<Patient?> getPatientById(String patientId) async {
    final db = await database;
    final result = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [patientId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Patient.fromMap(result.first);
  }

  Future<void> insertVitalSign(VitalSign vitalSign) async {
    final db = await database;
    await db.insert('vital_signs', vitalSign.toMap());
  }

  Future<List<VitalSign>> getVitalSignsForPatient(String patientId) async {
    final db = await database;
    final result = await db.query(
      'vital_signs',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'recorded_at DESC',
    );
    return result.map(VitalSign.fromMap).toList();
  }

  Future<void> upsertVaccinationRecord(VaccinationRecord record) async {
    final db = await database;
    await db.insert(
      'vaccination_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<VaccinationRecord?> getVaccinationRecordForPatient(
    String patientId,
  ) async {
    final db = await database;
    final result = await db.query(
      'vaccination_records',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return VaccinationRecord.fromMap(result.first);
  }
}
