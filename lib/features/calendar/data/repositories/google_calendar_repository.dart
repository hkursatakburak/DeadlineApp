import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/calendar_event.dart';

part 'google_calendar_repository.g.dart';

@Riverpod(keepAlive: true)
GoogleCalendarRepository googleCalendarRepository(
    GoogleCalendarRepositoryRef ref) {
  return GoogleCalendarRepository();
}

class GoogleCalendarRepository {
  static const _scopes = [gcal.CalendarApi.calendarScope];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);

  GoogleSignInAccount? _currentUser;
  gcal.CalendarApi? _calendarApi;

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        await _initCalendarApi();
      }
      return _currentUser;
    } catch (e) {
      throw Exception('Google oturum açma hatası: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _calendarApi = null;
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    _currentUser = await _googleSignIn.signInSilently();
    if (_currentUser != null) {
      await _initCalendarApi();
    }
    return _currentUser;
  }

  Future<void> _initCalendarApi() async {
    if (_currentUser == null) return;
    final auth = await _currentUser!.authentication;
    final credentials = AccessCredentials(
      AccessToken(
        'Bearer',
        auth.accessToken ?? '',
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      auth.idToken,
      _scopes,
    );
    final client = authenticatedClient(http.Client(), credentials);
    _calendarApi = gcal.CalendarApi(client);
  }

  Future<List<CalendarEvent>> fetchEvents(
      DateTime start, DateTime end) async {
    if (_calendarApi == null) return [];
    try {
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: start.toUtc(),
        timeMax: end.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );
      return (events.items ?? []).map(_mapEvent).toList();
    } catch (e) {
      throw Exception('Takvim etkinlikleri alınamadı: $e');
    }
  }

  Future<String> createEvent(CalendarEvent event) async {
    if (_calendarApi == null) throw StateError('Google oturumu açık değil');
    final gcalEvent = _toGcalEvent(event);
    final created =
        await _calendarApi!.events.insert(gcalEvent, 'primary');
    return created.id ?? '';
  }

  Future<void> updateEvent(String eventId, CalendarEvent event) async {
    if (_calendarApi == null) return;
    await _calendarApi!.events
        .update(_toGcalEvent(event), 'primary', eventId);
  }

  Future<void> deleteEvent(String eventId) async {
    if (_calendarApi == null) return;
    await _calendarApi!.events.delete('primary', eventId);
  }

  CalendarEvent _mapEvent(gcal.Event e) {
    final start = e.start?.dateTime ?? e.start?.date ?? DateTime.now();
    final end = e.end?.dateTime ?? e.end?.date;
    return CalendarEvent(
      id: e.id ?? '',
      title: e.summary ?? '',
      start: start,
      end: end,
      description: e.description,
      isAllDay: e.start?.date != null,
    );
  }

  gcal.Event _toGcalEvent(CalendarEvent event) {
    return gcal.Event(
      summary: event.title,
      description: event.description,
      start: gcal.EventDateTime(
        dateTime: event.start.toUtc(),
        timeZone: 'UTC',
      ),
      end: gcal.EventDateTime(
        dateTime: (event.end ?? event.start.add(const Duration(hours: 1)))
            .toUtc(),
        timeZone: 'UTC',
      ),
    );
  }
}
