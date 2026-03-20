import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  late String title;
  DateTime? dueDate;
  String? googleCalendarEventId;
  late bool isCompleted;

  /// 0=düşük 1=orta 2=yüksek 3=kritik
  late int priority;

  List<String> tags = [];

  late bool isRepeating;

  /// 'daily' | 'weekly' | 'monthly'
  String? repeatRule;

  final subTasks = IsarLinks<SubTaskItem>();

  late DateTime createdAt;
}

@collection
class SubTaskItem {
  Id id = Isar.autoIncrement;

  late String title;
  late bool isCompleted;
}
