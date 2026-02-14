import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/app_config.dart';           // ⬅ ajusta la ruta si tu AppConfig está en otro lado
import '../data/auth_repository.dart';
import '../models/notification_item.dart';
import '../models/notification_summary.dart';

class NotificationRepository {
    final AuthRepository _auth = AuthRepository();
    final http.Client _client;

    NotificationRepository({http.Client? client})
        : _client = client ?? http.Client();

    Uri _uri(String path) {
        
        return Uri.parse('${AppConfig.apiBaseUrl}$path');
    }

    Future<Map<String, String>> _headers() async {
        final token = await _auth.getToken();

        final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        };

        if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        }

        return headers;
    }

    void _throwIfError(http.Response resp) {
        if (resp.statusCode >= 200 && resp.statusCode < 300) return;
        throw Exception('Error HTTP ${resp.statusCode}: ${resp.statusCode} - ${resp.body}');
    }

    /// 🔔 Obtener lista de notificaciones
    Future<List<NotificationItem>> obtenerNotificaciones() async {
        final resp = await _client.get(
        _uri('/notificaciones'),
        headers: await _headers(),
        );
        _throwIfError(resp);

        final data = jsonDecode(resp.body) as List<dynamic>;
        return data
            .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
            .toList();
    }

    /// 🔴 Obtener resumen (total y no leídas) para el globito rojo
    Future<NotificationSummary> obtenerResumen() async {
        final resp = await _client.get(
        _uri('/notificaciones/resumen'),
        headers: await _headers(),
        );
        _throwIfError(resp);

        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return NotificationSummary.fromJson(data);
    }

    /// ✅ Marcar como leída
    Future<void> marcarComoLeida(int id) async {
        final resp = await _client.post(
        _uri('/notificaciones/leida/$id'),
        headers: await _headers(),
        body: jsonEncode({}),
        );
        _throwIfError(resp);
    }
}
