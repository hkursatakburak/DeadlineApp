import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
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

  /// Strip Quill Delta JSON to plain text
  @ignore
  String get plainTextPreview {
    try {
      if (contentJson.isEmpty) return '';
      final doc = Document.fromJson(jsonDecode(contentJson));
      String plain = doc.toPlainText().trim();
      
      if (plain.length > 100) {
        return '${plain.substring(0, 100)}...';
      }
      return plain;
    } catch (_) {
      return '';
    }
  }
}
