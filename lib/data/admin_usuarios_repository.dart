import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/api_client.dart';
import '../models/admin_user.dart';

class AdminUsuariosRepository {
    final ApiClient _api = ApiClient();

    // ────────────────────────────────────────────────
    // LISTAR USUARIOS
    // ────────────────────────────────────────────────
    Future<List<AdminUser>> listar() async {
        final http.Response resp = await _api.get('/admin/usuarios');

        if (resp.statusCode != 200) {
        throw Exception('Error ${resp.statusCode} al listar usuarios');
        }

        final data = ApiClient.decodeJson(resp);

        final list = (data is Map<String, dynamic>) ? data['data'] : data;

        return (list as List)
            .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
            .toList();
    }

    // ────────────────────────────────────────────────
    // CAMBIAR ESTADO  (TOGGLE ACTIVO/INACTIVO)
    // ────────────────────────────────────────────────
    Future<void> cambiarEstado(int id, bool activo) async {
        final http.Response resp = await _api.put(
        '/admin/usuarios/$id/estado',          // 👈 IMPORTANTE: PUT + /estado
        body: jsonEncode(<String, dynamic>{
            'activo': activo ? 1 : 0,            // mismo campo que usas en crear/editar
        }),
        );

        // Aceptamos 200 ó 204 como "ok"
        if (resp.statusCode != 200 && resp.statusCode != 204) {
        try {
            final data = ApiClient.decodeJson(resp);
            final msg = (data is Map && data['message'] != null)
                ? data['message'].toString()
                : 'No se pudo actualizar el estado del usuario '
                '(código ${resp.statusCode})';
            throw Exception(msg);
        } catch (_) {
            throw Exception(
            'No se pudo actualizar el estado del usuario '
            '(código ${resp.statusCode})',
            );
        }
        }
    }

    // ────────────────────────────────────────────────
    // ELIMINAR USUARIO
    // ────────────────────────────────────────────────
    Future<void> eliminar(int id) async {
        final resp = await _api.delete('/admin/usuarios/$id');

        Map<String, dynamic>? data;
        try {
        if (resp.body.isNotEmpty) {
            data = ApiClient.decodeJson(resp) as Map<String, dynamic>;
        }
        } catch (_) {
        data = null;
        }

        if (resp.statusCode == 409) {
        final msg = data?['message'] ??
            'Este usuario no puede eliminarse porque tiene movimientos en el sistema.';
        throw Exception(msg);
        }

        if (resp.statusCode != 200 && resp.statusCode != 204) {
        final msg = data?['message'] ??
            'No se pudo eliminar usuario (código ${resp.statusCode})';
        throw Exception(msg);
        }
    }

    // ────────────────────────────────────────────────
    // CREAR USUARIO
    // ────────────────────────────────────────────────
    Future<void> crearUsuario({
        required String nombre,
        required String correo,
        required String password,
        required String rol,
        required bool activo,
    }) async {
        final resp = await _api.post(
        '/admin/usuarios',
        body: jsonEncode({
            'nombre': nombre,
            'correo': correo,
            'password': password,
            'role': rol,
            'activo': activo ? 1 : 0,
        }),
        );

        if (resp.statusCode != 201) {
        try {
            final data = ApiClient.decodeJson(resp);
            final msg =
                data['message'] ?? 'Error ${resp.statusCode} al crear usuario';
            throw Exception(msg);
        } catch (_) {
            throw Exception('Error ${resp.statusCode} al crear usuario');
        }
        }
    }

    // ────────────────────────────────────────────────
    // ACTUALIZAR USUARIO
    // ────────────────────────────────────────────────
    Future<void> actualizarUsuario({
        required int id,
        required String nombre,
        required String correo,
        required String role,
        required bool activo,
        String? password,
    }) async {
        final body = <String, dynamic>{
        'nombre': nombre,
        'correo': correo,
        'role': role,
        'activo': activo ? 1 : 0,
        };

        if (password != null && password.isNotEmpty) {
        body['password'] = password;
        }

        final resp = await _api.put(
        '/admin/usuarios/$id',
        body: jsonEncode(body),
        );

        if (resp.statusCode != 200) {
        try {
            final data = ApiClient.decodeJson(resp);
            final msg = data['message'] ??
                'Error ${resp.statusCode} al actualizar usuario';
            throw Exception(msg);
        } catch (_) {
            throw Exception('Error ${resp.statusCode} al actualizar usuario');
        }
        }
    }
}
