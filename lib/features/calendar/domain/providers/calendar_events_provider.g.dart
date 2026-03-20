// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_events_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarEventsHash() => r'0ca06979c7b895923b46330bcd1e84bb480d05d5';

/// See also [calendarEvents].
@ProviderFor(calendarEvents)
final calendarEventsProvider =
    AutoDisposeFutureProvider<List<CalendarEvent>>.internal(
  calendarEvents,
  name: r'calendarEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CalendarEventsRef = AutoDisposeFutureProviderRef<List<CalendarEvent>>;
String _$calendarSyncServiceHash() =>
    r'3033dcbf70fd2c10c919f6bf65f0f2860122a1e5';

/// See also [calendarSyncService].
@ProviderFor(calendarSyncService)
final calendarSyncServiceProvider =
    AutoDisposeProvider<CalendarSyncService>.internal(
  calendarSyncService,
  name: r'calendarSyncServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarSyncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CalendarSyncServiceRef = AutoDisposeProviderRef<CalendarSyncService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
