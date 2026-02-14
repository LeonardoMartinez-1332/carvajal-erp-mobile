import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import '../config/api_config.dart';

class ProductImportService {
    final Dio _dio;

    ProductImportService(String token)
        : _dio = Dio(BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 120),
            ));

    Future<Map<String, dynamic>> uploadExcelFile(
        File file, {
        void Function(int, int)? onSendProgress,
    }) async {
        final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: p.basename(file.path)),
        });

        final resp = await _dio.post(
        '/products/import',
        data: form,
        onSendProgress: onSendProgress,
        options: Options(validateStatus: (c) => c != null && c < 600), // deja pasar 4xx/5xx
        );

        final status = resp.statusCode ?? 0;
        final data = resp.data;

        // 1) Si ya es un Map, perfecto.
        if (data is Map<String, dynamic>) return data;

        // 2) Si es String, intenta parsear JSON; si no, devuélvelo como texto.
        if (data is String) {
        try {
            final parsed = json.decode(data);
            if (parsed is Map<String, dynamic>) return parsed;
        } catch (_) {}
        final preview = data.length > 300 ? '${data.substring(0, 300)}…' : data;
        return {'ok': false, 'status': status, 'message': 'HTTP $status', 'raw': preview};
        }

        // 3) Cualquier otra cosa:
        return {
        'ok': false,
        'status': status,
        'message': 'HTTP $status: ${data.runtimeType}',
        };
    }
}