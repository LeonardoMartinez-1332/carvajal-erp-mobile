// lib/data/jobs_repository.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../data/api_client.dart';               // 👈 usa base URL real + token
import 'package:carvajal_erp/models/job_product.dart';
import 'package:carvajal_erp/models/ti_directa.dart';          // TiDirecta + TiLineaCreate
import 'package:carvajal_erp/models/ti_directa_resumen.dart';  // Resumen para historial

class JobsRepository {
    final ApiClient _api = ApiClient();

    // =======================
    //  Productos con stock
    // =======================
    Future<List<JobProduct>> getProductos({int? almacenId}) async {
        // ANTES: http://127.0.0.1:8000/api/jobs/productos?almacen_id=...
        String path = '/jobs/productos';
        if (almacenId != null) {
        path += '?almacen_id=${almacenId.toString()}';
        }

        final http.Response resp = await _api.get(path);

        if (resp.statusCode != 200) {
        throw Exception('Error al cargar productos: ${resp.body}');
        }

        final data = ApiClient.decodeJson(resp);

        final List list =
            (data is Map<String, dynamic> && data['data'] != null)
                ? data['data'] as List
                : data as List;

        return list.map((e) => JobProduct.fromJson(e as Map<String, dynamic>)).toList();
    }

    // =======================
    //  Crear TI directa (Jobs)
    // =======================
    /// Regresa SOLO el folio (num_ti) como String.
    Future<String> crearTi({
        required int almacenOrigenId,
        required int almacenDestinoId,
        String? comentario,
        required List<TiLineaCreate> lineas,
    }) async {
        // ANTES: POST a http://127.0.0.1:8000/api/jobs/ti
        final body = {
        'almacen_origen_id': almacenOrigenId,
        'almacen_destino_id': almacenDestinoId,
        'comentario': comentario,
        'lineas': lineas.map((e) => e.toJson()).toList(),
        };

        final http.Response resp = await _api.post(
        '/jobs/ti',
        body: jsonEncode(body),
        );

        if (resp.statusCode != 201 && resp.statusCode != 200) {
        throw Exception('Error al crear TI: ${resp.body}');
        }

        final decoded = ApiClient.decodeJson(resp);

        // Puede venir como { message, data: { ...ti... } } o directo { ...ti... }
        Map<String, dynamic> tiJson;
        if (decoded is Map<String, dynamic> && decoded['data'] is Map) {
        tiJson = decoded['data'] as Map<String, dynamic>;
        } else if (decoded is Map<String, dynamic>) {
        tiJson = decoded;
        } else {
        // Evitamos indexar con [0] ni cosas raras
        throw Exception('Respuesta inesperada del servidor al crear TI');
        }

        final folio = (tiJson['num_ti'] ?? tiJson['folio'] ?? '').toString();
        return folio;
    }

    // =======================
    //  Historial de TI (Jobs)
    // =======================
    Future<List<TiDirectaResumen>> obtenerHistorialTi() async {
        // ANTES: GET http://127.0.0.1:8000/api/jobs/ti
        final http.Response resp = await _api.get('/jobs/ti');

        if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception(
            'Error ${resp.statusCode} al cargar historial TI: ${resp.body}',
        );
        }

        final decoded = ApiClient.decodeJson(resp);

        List list = const [];

        if (decoded is Map<String, dynamic>) {
        // Soportamos varios formatos: {data:[...]}, {tis:[...]}, o incluso paginación {data:{data:[...]}}
        if (decoded['data'] is List) {
            list = decoded['data'] as List;
        } else if (decoded['tis'] is List) {
            list = decoded['tis'] as List;
        } else if (decoded['data'] is Map &&
            (decoded['data'] as Map)['data'] is List) {
            list = (decoded['data'] as Map)['data'] as List;
        }
        } else if (decoded is List) {
        list = decoded;
        }

        return list
            .map((e) => TiDirectaResumen.fromJson(e as Map<String, dynamic>))
            .toList();
    }

    // =======================
    //  Detalle de TI
    // =======================
    Future<TiDirecta> verTi(int id) async {
        final http.Response resp = await _api.get('/jobs/ti/$id');

        // print('=== verTi $id ===');
        // print(resp.body);

        if (resp.statusCode != 200) {
        throw Exception('Error al obtener TI: ${resp.body}');
        }

        final data = ApiClient.decodeJson(resp);
        final json =
            (data is Map<String, dynamic> && data['data'] != null)
                ? data['data'] as Map<String, dynamic>
                : data as Map<String, dynamic>;

        return TiDirecta.fromJson(json);
    }

    // =======================
    //  PDF de TI
    // =======================
    Future<Uint8List> descargarPdfTi(int id) async {
        final http.Response resp = await _api.get('/jobs/ti/$id/pdf');

        if (resp.statusCode != 200) {
        throw Exception('Error al descargar PDF: ${resp.statusCode}');
        }

        return resp.bodyBytes;
    }
}
