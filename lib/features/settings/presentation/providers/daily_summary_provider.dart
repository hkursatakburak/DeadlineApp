import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/notification_service.dart';

class DailySummaryState {
  final bool isEnabled;
  final TimeOfDay? time;

  const DailySummaryState({this.isEnabled = false, this.time});

  DailySummaryState copyWith({bool? isEnabled, TimeOfDay? time}) {
    return DailySummaryState(
      isEnabled: isEnabled ?? this.isEnabled,
      time: time ?? this.time,
    );
  }
}

class DailySummaryNotifier extends Notifier<DailySummaryState> {
  static const _enabledKey = 'daily_summary_enabled';
  static const _hourKey = 'daily_summary_hour';
  static const _minuteKey = 'daily_summary_minute';

  @override
  DailySummaryState build() {
    // Return an initial state. 
    // This allows UI to build immediately while init() runs.
    return const DailySummaryState();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_enabledKey) ?? false;
    final hour = prefs.getInt(_hourKey);
    final minute = prefs.getInt(_minuteKey);

    TimeOfDay? time;
    if (hour != null && minute != null) {
      time = TimeOfDay(hour: hour, minute: minute);
    }

    state = DailySummaryState(isEnabled: isEnabled, time: time);
  }

  Future<void> setSummary(bool enabled, [TimeOfDay? time]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);

    if (time != null) {
      await prefs.setInt(_hourKey, time.hour);
      await prefs.setInt(_minuteKey, time.minute);
    }

    final updatedTime = time ?? state.time;
    state = state.copyWith(isEnabled: enabled, time: updatedTime);

    // Trigger local notification scheduling logic
    if (enabled && updatedTime != null) {
      await NotificationService().scheduleDailySummary(updatedTime.hour, updatedTime.minute);
    } else {
      await NotificationService().cancelDailySummary();
    }
  }
}

final dailySummaryProvider = NotifierProvider<DailySummaryNotifier, DailySummaryState>(
  () => DailySummaryNotifier(),
);
