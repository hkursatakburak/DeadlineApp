// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncStatusHash() => r'6f42daea4b48e0c45d5e5449bf84f48345f76577';

/// See also [syncStatus].
@ProviderFor(syncStatus)
final syncStatusProvider = AutoDisposeProvider<SyncStatus>.internal(
  syncStatus,
  name: r'syncStatusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SyncStatusRef = AutoDisposeProviderRef<SyncStatus>;
String _$googleAuthNotifierHash() =>
    r'6a2f50856b5e2d35e1ed1902800cf2c55cd52651';

/// See also [GoogleAuthNotifier].
@ProviderFor(GoogleAuthNotifier)
final googleAuthNotifierProvider =
    NotifierProvider<GoogleAuthNotifier, GoogleAuthState>.internal(
  GoogleAuthNotifier.new,
  name: r'googleAuthNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$googleAuthNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GoogleAuthNotifier = Notifier<GoogleAuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
