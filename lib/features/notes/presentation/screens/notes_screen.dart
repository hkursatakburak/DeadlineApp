import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/providers/notes_provider.dart';
import '../../data/models/note.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/theme/app_colors.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesNotifierProvider);
    final notifier = ref.read(notesNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlar'),
        actions: [
          IconButton(
            icon: Icon(
              notifier.showArchived ? Icons.archive : Icons.archive_outlined,
            ),
            tooltip: notifier.showArchived
                ? 'Arşivi Gizle'
                : 'Arşivlenenleri Göster',
            onPressed: () => notifier.toggleShowArchived(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Not ara…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
        ),
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorWidget(message: e.toString(), onRetry: () => ref.invalidate(notesNotifierProvider)),
        data: (notes) {
          final filtered = _applySearch(notes);
          if (filtered.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note_add_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Henüz not yok', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          // Pinned first
          final pinned = filtered.where((n) => n.isPinned).toList();
          final rest = filtered.where((n) => !n.isPinned).toList();
          final all = [...pinned, ...rest];

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: all.length,
            itemBuilder: (ctx, i) => _NoteCard(
              note: all[i],
              onTap: () => context.go('/notes/edit?id=${all[i].id}'),
              onPin: () => notifier.togglePin(all[i].id),
              onArchive: () => notifier.toggleArchive(all[i].id),
              onDelete: () => notifier.delete(all[i].id),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: (i * 40).ms)
                .slideY(begin: 0.3, duration: 300.ms),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/notes/edit'),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Not'),
      ),
    );
  }

  List<Note> _applySearch(List<Note> notes) {
    if (_searchQuery.isEmpty) return notes;
    return notes.where((n) {
      final titleMatch = n.title.toLowerCase().contains(_searchQuery);
      final tagMatch =
          n.tags.any((t) => t.toLowerCase().contains(_searchQuery));
      return titleMatch || tagMatch;
    }).toList();
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isPinned)
                      const Icon(Icons.push_pin, size: 16,
                          color: AppColors.deadlineRed),
                  ],
                ),
                if (note.plainTextPreview.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    note.plainTextPreview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: note.tags
                        .take(4)
                        .map((t) => Chip(
                              label: Text(t, style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  AppDateUtils.relativeTime(note.updatedAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.push_pin_outlined),
              title: Text(note.isPinned ? 'Sabitliği Kaldır' : 'Sabitle'),
              onTap: () {
                Navigator.pop(context);
                onPin();
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(note.isArchived ? 'Arşivden Çıkar' : 'Arşivle'),
              onTap: () {
                Navigator.pop(context);
                onArchive();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Sil', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        Text('Hata: $message', textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Tekrar Dene'),
        ),
      ],
    ),
  );
}
