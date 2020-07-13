import 'dart:io';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'PatientsVisitTable.g.dart';

class PatientsVisit extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mobileNo => integer()();
  IntColumn get age => integer().nullable()();
  TextColumn get patientName => text()();
  IntColumn get temperature => integer().withDefault(Constant(98))();
  IntColumn get pulse => integer().withDefault(Constant(60))();
  IntColumn get weight => integer().nullable()();
  IntColumn get patientId => integer()();
  IntColumn get clinicDoctorId => integer().nullable()();
  TextColumn get briefHistory => text()();
  TextColumn get visitReason => text()();
  TextColumn get examination => text()();
  TextColumn get diagnosis => text()();
  TextColumn get medication => text()();
  TextColumn get allergies => text()();
  TextColumn get lifestyle => text()();
  BoolColumn get isOnline => boolean().withDefault(Constant(false))();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'PatientsVisitDBtable.sqlite'));
    return VmDatabase(file, logStatements: true);
  });
}

@UseMoor(tables: [PatientsVisit])
class PatientsVisitDB extends _$PatientsVisitDB {
  PatientsVisitDB() : super(_openConnection());
  @override
  int get schemaVersion => 1;
}