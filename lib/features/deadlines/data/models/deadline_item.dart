import 'package:isar/isar.dart';

part 'deadline_item.g.dart';

@collection
class DeadlineItem {
  Id id = Isar.autoIncrement;

  late String title;
  late DateTime dueDate;
  String? description;
  String? googleCalendarEventId;
  late bool isCompleted;

  /// 0=düşük 1=orta 2=yüksek 3=kritik
  late int priority;

  late DateTime createdAt;

  bool get isOverdue =>
      !isCompleted && dueDate.isBefore(DateTime.now());

  int get daysRemaining =>
      dueDate.toLocal().difference(DateTime.now()).inDays;
}
