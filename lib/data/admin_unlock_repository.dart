import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/unlock_request.dart';
import 'auth_repository.dart';

class AdminUnlockRepository {
    final String baseUrl;
    final AuthRepository auth;

    AdminUnlockRepository({
        required this.baseUrl,
        required this.auth,
    });

    Future<List<UnlockRequest>> listarPendientes() async {
        final token = await auth.getToken();

        final url = Uri.parse('$baseUrl/admin/unlock-requests?status=pendiente');

        if (kDebugMode) {
        print('[UNLOCK] GET $url');
        print('[UNLOCK] token: $token');
        }

        final resp = await http.get(
        url,
        headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        },
        );

        if (kDebugMode) {
        print('[UNLOCK] status: ${resp.statusCode}');
        print('[UNLOCK] body: ${resp.body}');
        }

        // 🔹 Si no es 200, mostramos el código real y el cuerpo
        if (resp.statusCode != 200) {
        throw Exception(
            'Error al cargar solicitudes (código ${resp.statusCode})',
        );
        }

        final data = jsonDecode(resp.body);

        // 🔹 Por si el backend regresa { "data": [ ... ] }
        final list = (data is List) ? data : (data['data'] as List);

        return list.map((e) => UnlockRequest.fromJson(e)).toList();
    }

    Future<void> aprobar(int id) async {
        final token = await auth.getToken();
        final url = Uri.parse('$baseUrl/admin/unlock-requests/$id/approve');

        final resp = await http.post(
        url,
        headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        },
        );

        if (resp.statusCode != 200) {
        if (kDebugMode) {
            print('[UNLOCK] aprobar error: ${resp.statusCode} ${resp.body}');
        }
        throw Exception('Error al aprobar la solicitud');
        }
    }

    Future<void> rechazar(int id) async {
        final token = await auth.getToken();
        final url = Uri.parse('$baseUrl/admin/unlock-requests/$id/reject');

        final resp = await http.post(
        url,
        headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        },
        );

        if (resp.statusCode != 200) {
        if (kDebugMode) {
            print('[UNLOCK] rechazar error: ${resp.statusCode} ${resp.body}');
        }
        throw Exception('Error al rechazar la solicitud');
        }
    }
}
