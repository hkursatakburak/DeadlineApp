import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/note.dart';
import '../../domain/providers/notes_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final int? noteId;
  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late QuillController _quillCtrl;
  final _titleCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final List<String> _tags = [];
  bool _isNew = true;
  Note? _existingNote;

  @override
  void initState() {
    super.initState();
    _isNew = widget.noteId == null;
    _quillCtrl = QuillController.basic();

    if (!_isNew) {
      // Load note after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadNote());
    }
  }

  Future<void> _loadNote() async {
    final notes = ref.read(notesNotifierProvider).valueOrNull;
    final note = notes?.where((n) => n.id == widget.noteId).firstOrNull;

    if (note != null) {
      _existingNote = note;
      _titleCtrl.text = note.title;
      _tags.clear();
      _tags.addAll(note.tags);
      try {
        final doc = Document();
        _quillCtrl = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        _quillCtrl = QuillController.basic();
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _save({bool silent = false}) async {
    final title = _titleCtrl.text.trim();
    final content = _quillCtrl.document.toDelta().toJson().toString();
    final notifier = ref.read(notesNotifierProvider.notifier);

    final newNote = Note()
      ..title = title.isEmpty ? 'Başlıksız Not' : title
      ..contentJson = content
      ..tags = List.from(_tags)
      ..isPinned = _existingNote?.isPinned ?? false
      ..isArchived = _existingNote?.isArchived ?? false
      ..createdAt = _existingNote?.createdAt ?? DateTime.now().toUtc()
      ..updatedAt = DateTime.now().toUtc();

    if (_isNew) {
      await notifier.add(newNote);
      _isNew = false;
    } else {
      newNote.id = widget.noteId!;
      await notifier.saveNote(newNote);
    }

    if (!silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not kaydedildi'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagCtrl.clear();
      });
    }
  }

  @override
  void dispose() {
    _quillCtrl.dispose();
    _titleCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_isNew ? 'Yeni Not' : 'Notu Düzenle'),
        actions: [
          TextButton.icon(
            onPressed: () => _save(),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Kaydet'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Not başlığı',
                  border: InputBorder.none,
                  filled: false,
                ),
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
              ),
            ),
            // Quill toolbar
            QuillSimpleToolbar(
              controller: _quillCtrl,
              config: const QuillSimpleToolbarConfig(
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showListBullets: true,
                showListNumbers: true,
                showQuote: true,
                showHeaderStyle: true,
                showUndo: true,
                showRedo: true,
                showColorButton: false,
                showBackgroundColorButton: false,
                showFontFamily: false,
                showFontSize: false,
                showAlignmentButtons: false,
                showIndent: false,
                showLink: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
                showSmallButton: false,
              ),
            ),
            const Divider(height: 1),
            // Editor
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuillEditor.basic(
                  controller: _quillCtrl,
                  config: const QuillEditorConfig(
                    placeholder: 'Notunuzu buraya yazın…',
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            // Tags - footer section
            Material(
              elevation: 4,
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  MediaQuery.viewInsetsOf(context).bottom > 0 ? 4 : 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_tags.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _tags
                              .map((t) => Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Chip(
                                      label: Text(t,
                                          style: const TextStyle(fontSize: 12)),
                                      visualDensity: VisualDensity.compact,
                                      deleteIcon:
                                          const Icon(Icons.close, size: 14),
                                      onDeleted: () =>
                                          setState(() => _tags.remove(t)),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Etiket ekle',
                              isDense: true,
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 14),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: _addTag,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
