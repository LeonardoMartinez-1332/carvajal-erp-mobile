import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../offline/session_store.dart';

class UnauthorizedException implements Exception {
    final String message;
    UnauthorizedException([this.message = 'No autorizado']);

    @override
    String toString() => message;
}

class ApiClient {
    // Ya no es const. Usamos un getter que lee AppConfig.
    static String get baseUrl => AppConfig.apiBaseUrl;

    final SessionStore _store = SessionStore();

    Future<http.Response> _handle(http.Response r) async {
        if (r.statusCode == 401) {
        await _store.clear();
        throw UnauthorizedException();
        }
        return r;
    }

    Future<http.Response> post(
        String path, {
        Map<String, String>? headers,
        Object? body,
    }) async {
        final token = await _store.token;
        final allHeaders = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
        };

        final uri = Uri.parse('$baseUrl$path');
        final r = await http
            .post(uri, headers: allHeaders, body: body)
            .timeout(const Duration(seconds: 15));

        return _handle(r);
    }

    Future<http.Response> get(
        String path, {
        Map<String, String>? headers,
    }) async {
        final token = await _store.token;
        final allHeaders = <String, String>{
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
        };

        final uri = Uri.parse('$baseUrl$path');
        final r = await http
            .get(uri, headers: allHeaders)
            .timeout(const Duration(seconds: 15));

        return _handle(r);
    }

    Future<http.Response> put(
        String path, {
        Map<String, String>? headers,
        Object? body,
    }) async {
        final token = await _store.token;
        final allHeaders = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
        };

        final uri = Uri.parse('$baseUrl$path');
        final r = await http
            .put(uri, headers: allHeaders, body: body)
            .timeout(const Duration(seconds: 15));

        return _handle(r);
    }

    Future<http.Response> delete(
        String path, {
        Map<String, String>? headers,
    }) async {
        final token = await _store.token;
        final allHeaders = <String, String>{
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
        };

        final uri = Uri.parse('$baseUrl$path');
        final r = await http
            .delete(uri, headers: allHeaders)
            .timeout(const Duration(seconds: 15));

        return _handle(r);
    }

    static dynamic decodeJson(http.Response resp) {
        return json.decode(utf8.decode(resp.bodyBytes));
    }
}
