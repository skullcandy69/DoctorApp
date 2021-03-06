import 'dart:io';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'HabitsTable.g.dart';

enum Type { Allergy, LifeStyle }

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clinicDoctorId => integer().nullable()();
  IntColumn get doctorId => integer()();
  TextColumn get title => text()();
  IntColumn get type => intEnum<Type>()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isOnline => boolean().withDefault(Constant(false))();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'getHabits.sqlite'));
    return VmDatabase(file, logStatements: true);
  });
}

@UseMoor(tables: [Habits])
class HabitDB extends _$HabitDB {
  HabitDB() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<Habit>> watchAllTasks(String q) {
    dynamic query;
    if (q.length != 0) {
      query = select(habits)..where((t) => t.title.contains(q));
    } else {
      query = select(habits);
    }
    return query.watch();
  }

  Future insertAllergy(String allergyName, int docId) {
    Habit habit = Habit(
      doctorId: docId,
      title: allergyName,
      type: Type.Allergy,
    );
    into(habits).insert(habit);
  }

  Future insertLifeStyle(String lifeName, int docId) {
    Habit habit = Habit(
      doctorId: docId,
      title: lifeName,
      type: Type.LifeStyle,
    );
    into(habits).insert(habit);
  }
}
