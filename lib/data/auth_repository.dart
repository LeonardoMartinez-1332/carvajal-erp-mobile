import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import '../offline/session_store.dart';
import 'api_client.dart';
import '../core/app_config.dart';


/// Excepción pro para interpretar respuestas de la API
class ApiException implements Exception {
    final int statusCode;
    final String message;
    final String? code;

    ApiException(this.statusCode, this.message, {this.code});

    @override
    String toString() => 'ApiException($statusCode, $code, $message)';
}

class AuthRepository {
    final ApiClient _api = ApiClient();
    final SessionStore _store = SessionStore();

    static String get baseUrl => AppConfig.apiBaseUrl;

    // Claves para SecureStorage
    static const _kTokenKey = 'auth_token';
    static const _kUserKey = 'auth_user';
    final FlutterSecureStorage _secure = const FlutterSecureStorage();

    /// Login contra tu API.
    /// Respuesta esperada:
    /// { message, code, token, user:{ id,name,email,role,activo,... } }
    Future<UserModel> login({
        required String email,
        required String password,
    }) async {
        final resp = await _api.post(
        '/login',
        body: json.encode({'email': email, 'password': password}),
        );

        // ✅ Caso OK (200–299)
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final jsonMap = ApiClient.decodeJson(resp) as Map<String, dynamic>;
        final token = jsonMap['token']?.toString();
        final userMap = jsonMap['user'] as Map<String, dynamic>?;

        if (token == null || userMap == null) {
            throw ApiException(
            resp.statusCode,
            'Respuesta inválida del servidor.',
            code: 'invalid_response',
            );
        }

        final user = UserModel.fromMap(userMap);

        // Guarda sesión en tu SessionStore
        await _store.saveSession(
            token: token,
            role: user.role,
            userName: user.name,
        );

        // Guarda también en SecureStorage
        await _secure.write(key: _kTokenKey, value: token);
        await _secure.write(key: _kUserKey, value: jsonEncode(userMap));

        return user;
        }

        // ❌ Error → sacamos message + code del backend
        try {
        final map = ApiClient.decodeJson(resp) as Map<String, dynamic>;
        final msg = map['message']?.toString() ??
            'Error de autenticación (${resp.statusCode}).';
        final code = map['code']?.toString();

        throw ApiException(resp.statusCode, msg, code: code);
        } catch (_) {
        throw ApiException(
            resp.statusCode,
            'Error de autenticación (${resp.statusCode}).',
        );
        }
    }

    /// Valida el token contra /me y, si es válido, devuelve el usuario.
    Future<UserModel?> validateAndGetUser() async {
        try {
        final r = await _api.get('/me');

        if (r.statusCode == 200) {
            final map = ApiClient.decodeJson(r) as Map<String, dynamic>;
            final user = UserModel.fromMap(map);

            // Refrescamos el usuario en SecureStorage
            await _secure.write(key: _kUserKey, value: jsonEncode(map));

            return user;
        }

        // Token inválido / expirado → limpiamos todo
        await _store.clear();
        await _secure.delete(key: _kTokenKey);
        await _secure.delete(key: _kUserKey);
        return null;
        } catch (_) {
        await _store.clear();
        await _secure.delete(key: _kTokenKey);
        await _secure.delete(key: _kUserKey);
        return null;
        }
    }

    /// Versión booleana
    Future<bool> validateToken() async {
        final user = await validateAndGetUser();
        return user != null;
    }

    /// Lee el token actual
    Future<String?> getToken() async {
        return _secure.read(key: _kTokenKey);
    }

    /// Obtén el usuario guardado (sin ir a la red).
    Future<UserModel?> getUser() async {
        final raw = await _secure.read(key: _kUserKey);
        if (raw == null) return null;
        try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return UserModel.fromMap(map);
        } catch (_) {
        return null;
        }
    }

    /// Cierra sesión
    Future<void> logout() async {
        try {
        await _api.post('/logout');
        } catch (_) {
        // ignoramos errores
        } finally {
        await _store.clear();
        await _secure.delete(key: _kTokenKey);
        await _secure.delete(key: _kUserKey);
        }
    }

    /// Envía una solicitud de desbloqueo al backend.
    ///
    /// POST /auth/unlock-request
    ///
    /// Body: { email: ..., motivo: ...? }
    Future<void> solicitarDesbloqueo({
        required String email,
        String? motivo,
    }) async {
        final body = <String, dynamic>{
        'email': email,
        if (motivo != null && motivo.trim().isNotEmpty) 'motivo': motivo.trim(),
        };

        final resp = await _api.post(
        '/auth/unlock-request',
        body: jsonEncode(body),
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
        },
        );

        if (resp.statusCode == 200 || resp.statusCode == 201) {
        return; // OK
        }

        // Error → parseamos message + code
        try {
        final map = ApiClient.decodeJson(resp) as Map<String, dynamic>;
        final msg = map['message']?.toString() ??
            'No se pudo registrar la solicitud (${resp.statusCode}).';
        final code = map['code']?.toString();

        throw ApiException(resp.statusCode, msg, code: code);
        } catch (_) {
        throw ApiException(
            resp.statusCode,
            'No se pudo registrar la solicitud (${resp.statusCode}).',
        );
        }
    }
}
