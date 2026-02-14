import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'auth_repository.dart';

class AdminProductosRepository {
    final String baseUrl;
    final AuthRepository auth;

    AdminProductosRepository({
        required this.baseUrl,
        required this.auth,
    });

    Future<List<Product>> listar({String? search}) async {
        final token = await auth.getToken();

        if (token == null || token.isEmpty) {
        throw Exception('Token no disponible. Inicia sesión de nuevo.');
        }

        final uri = Uri.parse('$baseUrl/admin/productos').replace(
        queryParameters: {
            if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
        );

        final resp = await http.get(
        uri,
        headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        },
        );

        if (resp.statusCode != 200) {
        throw Exception(
            'Error al cargar productos (${resp.statusCode}): ${resp.body}',
        );
        }

        final data = jsonDecode(resp.body) as List<dynamic>;

        return data
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
    }

    Future<Product> crear(Product producto) async {
        final token = await auth.getToken();

        if (token == null || token.isEmpty) {
        throw Exception('Token no disponible. Inicia sesión de nuevo.');
        }

        final uri = Uri.parse('$baseUrl/admin/productos');

        final resp = await http.post(
        uri,
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(producto.toJson()),
        );

        if (resp.statusCode != 201 && resp.statusCode != 200) {
        throw Exception(
            'Error al crear producto (${resp.statusCode}): ${resp.body}',
        );
        }

        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return Product.fromJson(data);
    }

    Future<Product> actualizar(Product producto) async {
        final token = await auth.getToken();

        if (token == null || token.isEmpty) {
        throw Exception('Token no disponible. Inicia sesión de nuevo.');
        }

        final uri = Uri.parse('$baseUrl/admin/productos/${producto.id}');

        final resp = await http.put(
        uri,
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(producto.toJson()),
        );

        if (resp.statusCode != 200) {
        throw Exception(
            'Error al actualizar producto (${resp.statusCode}): ${resp.body}',
        );
        }

        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return Product.fromJson(data);
    }

    Future<void> eliminar(int id) async {
        final token = await auth.getToken();

        if (token == null || token.isEmpty) {
        throw Exception('Token no disponible. Inicia sesión de nuevo.');
        }

        final uri = Uri.parse('$baseUrl/admin/productos/$id');

        final resp = await http.delete(
        uri,
        headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        },
        );

        if (resp.statusCode != 200 && resp.statusCode != 204) {
        throw Exception(
            'Error al eliminar producto (${resp.statusCode}): ${resp.body}',
        );
        }
    }
}
