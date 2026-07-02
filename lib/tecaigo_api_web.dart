// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

const _apiBaseUrl = String.fromEnvironment(
  'TECAIGO_API_BASE_URL',
  defaultValue: 'https://tecaigo.onrender.com/api',
);

Future<List<Map<String, dynamic>>> fetchExeEvents() async {
  final response = await html.HttpRequest.request(
    '$_apiBaseUrl/events',
    method: 'GET',
    requestHeaders: const {'Accept': 'application/json'},
  );
  final data = jsonDecode(response.responseText ?? '{}');
  final events = data is Map ? data['events'] : null;
  if (events is! List) return [];
  return events
      .whereType<Map>()
      .map((event) => Map<String, dynamic>.from(event))
      .toList();
}

Future<bool> sendAppReservation(Map<String, dynamic> payload) async {
  final response = await html.HttpRequest.request(
    '$_apiBaseUrl/reservations',
    method: 'POST',
    requestHeaders: const {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    sendData: jsonEncode(payload),
  );
  return response.status != null &&
      response.status! >= 200 &&
      response.status! < 300;
}
