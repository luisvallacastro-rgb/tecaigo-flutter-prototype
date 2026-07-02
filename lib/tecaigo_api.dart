import 'tecaigo_api_stub.dart' if (dart.library.html) 'tecaigo_api_web.dart'
    as api;

Future<List<Map<String, dynamic>>> fetchExeEvents() => api.fetchExeEvents();

Future<bool> sendAppReservation(Map<String, dynamic> payload) =>
    api.sendAppReservation(payload);
