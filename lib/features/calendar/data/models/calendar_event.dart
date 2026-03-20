/// Google Calendar event model (not stored in Isar — transient)
class CalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end;
  final String? description;
  final bool isAllDay;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    this.description,
    this.isAllDay = false,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    DateTime? start,
    DateTime? end,
    String? description,
    bool? isAllDay,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      description: description ?? this.description,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }

  @override
  String toString() => 'CalendarEvent(id: $id, title: $title, start: $start)';
}
