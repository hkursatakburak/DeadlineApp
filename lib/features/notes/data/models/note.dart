import 'package:isar/isar.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  late String title;

  /// flutter_quill Delta JSON string
  late String contentJson;

  List<String> tags = [];

  late bool isPinned;
  late bool isArchived;

  late DateTime createdAt;
  late DateTime updatedAt;

  /// Strip Quill Delta JSON to plain text (very simple version)
  String get plainTextPreview {
    try {
      // Just return the raw string stripped of JSON brackets for preview
      return contentJson
          .replaceAll(RegExp(r'\{"insert":"'), '')
          .replaceAll(RegExp(r'"\}'), ' ')
          .replaceAll(RegExp(r'\[|\]|\{.*?\}'), '')
          .trim();
    } catch (_) {
      return '';
    }
  }
}
