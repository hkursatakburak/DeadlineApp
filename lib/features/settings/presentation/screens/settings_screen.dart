import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/theme_provider.dart';
import '../../../calendar/domain/providers/google_auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final authState = ref.watch(googleAuthNotifierProvider);
    final isSignedIn = authState.status == GoogleAuthStatus.signedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          // ── Hesap ──────────────────────────────────────────────────────────
          const _SectionHeader('Hesap'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              backgroundImage: authState.account?.photoUrl != null
                  ? NetworkImage(authState.account!.photoUrl!)
                  : null,
              child: authState.account?.photoUrl == null
                  ? const Icon(Icons.person_outline)
                  : null,
            ),
            title: Text(isSignedIn
                ? authState.account!.displayName ?? 'Google Hesabı'
                : 'Bağlı değil'),
            subtitle: Text(isSignedIn
                ? authState.account!.email
                : 'Google Takvim ile senkronize edin'),
            trailing: isSignedIn
                ? TextButton(
                    onPressed: () =>
                        ref.read(googleAuthNotifierProvider.notifier).signOut(),
                    child: const Text('Çıkış Yap',
                        style: TextStyle(color: Colors.red)),
                  )
                : FilledButton.icon(
                    onPressed: () =>
                        ref.read(googleAuthNotifierProvider.notifier).signIn(),
                    icon: const Icon(Icons.add_link, size: 16),
                    label: const Text('Bağlan'),
                  ),
          ),
          const Divider(),

          // ── Bildirimler ────────────────────────────────────────────────────
          const _SectionHeader('Bildirimler'),
          SwitchListTile(
            title: const Text('Deadline hatırlatıcıları'),
            subtitle: const Text('7, 3, 1 gün öncesi ve son gün'),
            value: true,
            onChanged: (v) {
              // TODO: persist with SharedPreferences
            },
          ),
          SwitchListTile(
            title: const Text('Günlük özet'),
            subtitle: const Text('Her gün seçilen saatte'),
            value: false,
            onChanged: (v) {
              // TODO: persist & schedule
            },
          ),
          const Divider(),

          // ── Genel ──────────────────────────────────────────────────────────
          const _SectionHeader('Genel'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Group Icon and Text and wrap in Expanded
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.palette_outlined, 
                           color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 16),
                      const Text(
                        'Tema',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                // Constrain SegmentedButton and use smaller labels to prevent squishing
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 210),
                  child: SegmentedButton<ThemeMode>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system, 
                        label: Text('Sistem', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light, 
                        label: Text('Açık', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark, 
                        label: Text('Koyu', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (s) => ref
                        .read(themeModeNotifierProvider.notifier)
                        .setTheme(s.first),
                    showSelectedIcon: false,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // ── Hakkında ───────────────────────────────────────────────────────
          const _SectionHeader('Hakkında'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Sürüm'),
            trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Yapımcı'),
            trailing:
                Text('DeadlineApp Team', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            leading: Icon(Icons.hourglass_empty),
            title: Text('Azrail hakkında'),
            subtitle: Text(
                'Zamanı takip eden, sizi yazan tasarımcıdan daha hızlı sayan yardımcınız.'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}
