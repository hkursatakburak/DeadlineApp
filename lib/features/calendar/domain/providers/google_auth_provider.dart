import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/google_calendar_repository.dart';

part 'google_auth_provider.g.dart';

enum GoogleAuthStatus { unknown, signedOut, signedIn, loading, error }

class GoogleAuthState {
  final GoogleAuthStatus status;
  final GoogleSignInAccount? account;
  final String? errorMessage;

  const GoogleAuthState({
    required this.status,
    this.account,
    this.errorMessage,
  });

  factory GoogleAuthState.initial() =>
      const GoogleAuthState(status: GoogleAuthStatus.unknown);
}

@Riverpod(keepAlive: true)
class GoogleAuthNotifier extends _$GoogleAuthNotifier {
  @override
  GoogleAuthState build() => GoogleAuthState.initial();

  Future<void> init() async {
    state = const GoogleAuthState(status: GoogleAuthStatus.loading);
    final repo = ref.read(googleCalendarRepositoryProvider);
    final account = await repo.signInSilently();
    state = account != null
        ? GoogleAuthState(status: GoogleAuthStatus.signedIn, account: account)
        : const GoogleAuthState(status: GoogleAuthStatus.signedOut);
  }

  Future<void> signIn() async {
    state = const GoogleAuthState(status: GoogleAuthStatus.loading);
    try {
      final repo = ref.read(googleCalendarRepositoryProvider);
      final account = await repo.signIn();
      state = account != null
          ? GoogleAuthState(
              status: GoogleAuthStatus.signedIn, account: account)
          : const GoogleAuthState(status: GoogleAuthStatus.signedOut);
    } catch (e) {
      state = GoogleAuthState(
        status: GoogleAuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    final repo = ref.read(googleCalendarRepositoryProvider);
    await repo.signOut();
    state = const GoogleAuthState(status: GoogleAuthStatus.signedOut);
  }
}

@riverpod
SyncStatus syncStatus(SyncStatusRef ref) => SyncStatus.idle;

enum SyncStatus { idle, syncing, done, error }
