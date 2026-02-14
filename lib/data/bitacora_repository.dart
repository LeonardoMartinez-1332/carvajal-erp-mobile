import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'api_client.dart';
import '../models/bitacora_entry.dart';

class BitacoraRepository {
    final ApiClient _api;

    // 🔹 BD local para pendientes de sincronizar
    static const _dbName = 'bitacora_sync.db';
    static const _pendingTable = 'bitacora_pendientes';

    Database? _db;

    BitacoraRepository({ApiClient? api}) : _api = api ?? ApiClient();

    // =========================================================
    // 🔹 Helpers de BD local
    // =========================================================
    Future<Database> get _database async {
        if (_db != null) return _db!;

        final dbPath = await getDatabasesPath();
        final fullPath = p.join(dbPath, _dbName);

        _db = await openDatabase(
        fullPath,
        version: 1,
        onCreate: (db, version) async {
            await db.execute('''
            CREATE TABLE $_pendingTable (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                payload TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
            ''');
        },
        );

        return _db!;
    }

    Future<void> _guardarPendiente(Map<String, dynamic> data) async {
        final db = await _database;

        await db.insert(
        _pendingTable,
        {
            'payload': jsonEncode(data),
            'created_at': DateTime.now().toIso8601String(),
        },
        );
    }

    Future<List<Map<String, dynamic>>> _obtenerPendientesRaw() async {
        final db = await _database;
        return db.query(
        _pendingTable,
        orderBy: 'id ASC',
        );
    }

    Future<void> _borrarPendiente(int id) async {
        final db = await _database;
        await db.delete(
        _pendingTable,
        where: 'id = ?',
        whereArgs: [id],
        );
    }

    // =========================================================
    // 🔹 API REMOTA – lo que ya tenías
    // =========================================================

    /// Listar bitácora (pantalla principal)
    Future<List<BitacoraEntry>> fetchBitacora({String? search}) async {
        final q = (search != null && search.trim().isNotEmpty)
            ? '?q=${Uri.encodeQueryComponent(search.trim())}'
            : '';

        final resp = await _api.get('/bitacora-camiones$q');

        if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = ApiClient.decodeJson(resp);
        if (data is List) {
            return data
                .map((e) => BitacoraEntry.fromJson(e as Map<String, dynamic>))
                .toList();
        }
        throw Exception('Formato inesperado de respuesta.');
        }

        throw Exception('Error al obtener bitácora (${resp.statusCode}).');
    }

    /// Alias
    Future<List<BitacoraEntry>> list({String? query}) {
        return fetchBitacora(search: query);
    }

    /// 🟥 Eliminar un registro
    Future<void> delete(int id) async {
        final resp = await _api.delete('/bitacora-camiones/$id');

        if (resp.statusCode >= 200 && resp.statusCode < 300) return;

        try {
        final body = ApiClient.decodeJson(resp);
        String msg = 'Error al eliminar (${resp.statusCode}).';

        if (body is Map<String, dynamic> && body['message'] != null) {
            msg = body['message'].toString();
        }

        throw Exception(msg);
        } catch (_) {
        throw Exception('Error al eliminar (${resp.statusCode}).');
        }
    }

    /// 🟢 Aprobar solicitud de bitácora (genera TI real en backend)
    /// POST /api/bitacora-camiones/{id}/aprobar
    Future<void> aprobar(int id) async {
        final resp = await _api.post('/bitacora-camiones/$id/aprobar');

        if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return;
        }

        try {
        final body = ApiClient.decodeJson(resp);
        String msg = 'Error al aprobar (${resp.statusCode}).';

        if (body is Map<String, dynamic> && body['message'] != null) {
            msg = body['message'].toString();
        }

        throw Exception(msg);
        } catch (_) {
        throw Exception('Error al aprobar (${resp.statusCode}).');
        }
    }

    /// 🔴 Rechazar solicitud de bitácora
    /// POST /api/bitacora-camiones/{id}/rechazar
    Future<void> rechazar(int id) async {
        final resp = await _api.post('/bitacora-camiones/$id/rechazar');

        if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return;
        }

        try {
        final body = ApiClient.decodeJson(resp);
        String msg = 'Error al rechazar (${resp.statusCode}).';

        if (body is Map<String, dynamic> && body['message'] != null) {
            msg = body['message'].toString();
        }

        throw Exception(msg);
        } catch (_) {
        throw Exception('Error al rechazar (${resp.statusCode}).');
        }
    }

    /// Listar solicitudes del supervisor (pendientes / aprobadas / rechazadas)
    Future<List<BitacoraEntry>> fetchMisSolicitudes({String? search}) async {
        final q = (search != null && search.trim().isNotEmpty)
            ? '?q=${Uri.encodeQueryComponent(search.trim())}'
            : '';

        final resp = await _api.get('/bitacora-camiones/mis-solicitudes$q');

        if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = ApiClient.decodeJson(resp);
        if (data is List) {
            return data
                .map((e) => BitacoraEntry.fromJson(e as Map<String, dynamic>))
                .toList();
        }
        throw Exception('Formato inesperado de respuesta.');
        }

        throw Exception('Error al obtener mis solicitudes (${resp.statusCode}).');
    }

    /// 🟦 UPDATE – sólo 3 campos editables
    ///
    /// PUT /api/bitacora-camiones/{id}
    Future<void> update(
        int id, {
        String? estado,
        String? rampa,
        String? horaSalida,
    }) async {
        final Map<String, dynamic> data = {};

        if (estado != null) data['estado'] = estado;
        // si viene vacía, mandamos null
        data['rampa'] = (rampa != null && rampa.isNotEmpty) ? rampa : null;
        data['hora_salida'] =
            (horaSalida != null && horaSalida.isNotEmpty) ? horaSalida : null;

        final resp = await _api.put(
        '/bitacora-camiones/$id',
        body: jsonEncode(data),
        );

        if (resp.statusCode >= 200 && resp.statusCode < 300) return;

        try {
        final body = ApiClient.decodeJson(resp);
        String msg = 'Error al actualizar (${resp.statusCode}).';

        if (body is Map<String, dynamic> && body['message'] != null) {
            msg = body['message'].toString();
        }

        throw Exception(msg);
        } catch (_) {
        throw Exception('Error al actualizar (${resp.statusCode}).');
        }
    }

    // =========================================================
    // 🟩 CREATE ONLINE – lógica tal cual la tenías
    // (la empaquetamos en helpers para reutilizarla)
    // =========================================================

    Map<String, dynamic> _buildCreatePayload({
        required String origen,
        required String destino,
        String? rampa,
        required String fecha,
        String? horaLlegada,
        String? horaSalida,
        required int idTurno,
        required int idTransp,
        required int cantidadTarimas,
        String estado = 'Programado',
    }) {
        final Map<String, dynamic> data = {
        'fecha': fecha,
        'hora_llegada': horaLlegada,
        'id_turno': idTurno,
        'id_transp': idTransp,
        'origen': origen,
        'destino': destino,
        'rampa': rampa,
        'estado': estado,
        'cantidad_tarimas': cantidadTarimas,
        'hora_salida': horaSalida,
        // id_supervisor lo asigna Laravel con Auth::user()->id
        };

        // Quitar los null
        data.removeWhere((key, value) => value == null);
        return data;
    }

    Future<void> _postCreate(Map<String, dynamic> data) async {
        final resp = await _api.post(
        '/bitacora-camiones',
        body: jsonEncode(data),
        );

        // ✅ OK (201 o 200)
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return;
        }

        // 🔍 Caso especial 422: mostrar errores de validación tal cual
        if (resp.statusCode == 422) {
        try {
            final body = ApiClient.decodeJson(resp);
            if (body is Map<String, dynamic>) {
            final errors = body['errors'];
            if (errors != null) {
                throw Exception('Validación fallida: $errors');
            }
            if (body['message'] != null) {
                throw Exception(body['message'].toString());
            }
            }
            throw Exception('Error de validación (422): ${resp.body}');
        } catch (_) {
            throw Exception('Error de validación (422): ${resp.body}');
        }
        }

        // Otros errores (401, 500, etc.)
        try {
        final body = ApiClient.decodeJson(resp);
        String msg = 'Error al crear (${resp.statusCode}).';

        if (body is Map<String, dynamic> && body['message'] != null) {
            msg = body['message'].toString();
        }

        throw Exception(msg);
        } catch (_) {
        throw Exception('Error al crear (${resp.statusCode}).');
        }
    }

    /// 🟩 CREATE – en línea (como antes)
    Future<void> create({
        required String origen,
        required String destino,
        String? rampa,
        required String fecha,
        String? horaLlegada,
        String? horaSalida,
        required int idTurno,
        required int idTransp,
        required int cantidadTarimas,
        String estado = 'Programado',
    }) async {
        final data = _buildCreatePayload(
        origen: origen,
        destino: destino,
        rampa: rampa,
        fecha: fecha,
        horaLlegada: horaLlegada,
        horaSalida: horaSalida,
        idTurno: idTurno,
        idTransp: idTransp,
        cantidadTarimas: cantidadTarimas,
        estado: estado,
        );

        await _postCreate(data);
    }

    // =========================================================
    // 🔄 CREATE OFFLINE-FIRST + SYNC DIFERIDA
    // =========================================================

    /// Crear registro con estrategia offline-first:
    /// - Si la API responde bien → se guarda en Laravel y listo.
    /// - Si falla por red (SocketException / Timeout) → se guarda localmente
    ///   en la tabla `bitacora_pendientes` para sincronizar después.
    Future<void> createOfflineFirst({
        required String origen,
        required String destino,
        String? rampa,
        required String fecha,
        String? horaLlegada,
        String? horaSalida,
        required int idTurno,
        required int idTransp,
        required int cantidadTarimas,
        String estado = 'Programado',
    }) async {
        final data = _buildCreatePayload(
        origen: origen,
        destino: destino,
        rampa: rampa,
        fecha: fecha,
        horaLlegada: horaLlegada,
        horaSalida: horaSalida,
        idTurno: idTurno,
        idTransp: idTransp,
        cantidadTarimas: cantidadTarimas,
        estado: estado,
        );

        try {
        await _postCreate(data); // intenta en línea
        } on SocketException catch (_) {
        // 💾 Sin red: guardar pendiente
        await _guardarPendiente(data);
        } on TimeoutException catch (_) {
        await _guardarPendiente(data);
        }
    }

    /// 🔃 Sincronizar todos los registros pendientes
    ///
    /// Devuelve cuántos se sincronizaron correctamente.
    Future<int> syncPendientes() async {
        final rows = await _obtenerPendientesRaw();
        int ok = 0;

        for (final row in rows) {
        final id = row['id'] as int;
        final payloadStr = row['payload'] as String;

        Map<String, dynamic> data;
        try {
            data = jsonDecode(payloadStr) as Map<String, dynamic>;
        } catch (_) {
            // Si el JSON está corrupto, borramos ese registro y seguimos
            await _borrarPendiente(id);
            continue;
        }

        try {
            await _postCreate(data);
            await _borrarPendiente(id);
            ok++;
        } on SocketException {
            // Sigue sin red, no borramos, lo reintentamos después
            continue;
        } on TimeoutException {
            continue;
        } catch (_) {
            // Error de validación u otro → a criterio se podría marcar como "error permanente".
            // Por simplicidad, lo dejamos para intentar de nuevo más tarde.
            continue;
        }
        }

        return ok;
    }

    /// Listar pendientes crudos (por si luego quieres mostrarlos en UI
    /// como "pendientes de sincronizar").
    Future<List<Map<String, dynamic>>> listarPendientesCrudos() {
        return _obtenerPendientesRaw();
    }

    /// Listar solicitudes pendientes de aprobación (solo admin)
    Future<List<BitacoraEntry>> fetchPendientes({String? search}) async {
        final q = (search != null && search.trim().isNotEmpty)
            ? '?q=${Uri.encodeQueryComponent(search.trim())}'
            : '';

        final resp = await _api.get('/bitacora-camiones/pendientes$q');

        if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = ApiClient.decodeJson(resp);
        if (data is List) {
            return data
                .map((e) => BitacoraEntry.fromJson(e as Map<String, dynamic>))
                .toList();
        }
        throw Exception('Formato inesperado de respuesta.');
        }

        throw Exception('Error al obtener pendientes (${resp.statusCode}).');
    }

      /// 🔍 Convierte la cola local de pendientes en una lista de BitacoraEntry
    /// para poder mostrarlos en la UI con `syncStatus = 'pending'`.
    Future<List<BitacoraEntry>> listarPendientesComoEntries() async {
        final rows = await _obtenerPendientesRaw();
        final List<BitacoraEntry> result = [];

        for (final row in rows) {
        final payloadStr = row['payload'] as String;
        Map<String, dynamic> payload;

        try {
            payload = jsonDecode(payloadStr) as Map<String, dynamic>;
        } catch (_) {
            // Si por alguna razón no se puede leer el JSON, lo saltamos
            continue;
        }

        // Armamos un mapa compatible con `fromLocalDb`
        final map = <String, dynamic>{
            'id': 0, // aún no tiene ID remoto
            'num_asn': '', // todavía sin ASN real
            'npi': null,
            'estatus_aprobacion': null,
            'placa': null,
            'origen': payload['origen'],
            'destino': payload['destino'],
            'rampa': payload['rampa'],
            'estado': payload['estado'] ?? 'Programado',
            'fecha': payload['fecha'],
            'hora_llegada': payload['hora_llegada'],
            'hora_salida': payload['hora_salida'],
            'cantidad_tarimas': payload['cantidad_tarimas'],
            'id_turno': payload['id_turno'],
            'id_transp': payload['id_transp'],
            'id_supervisor': null,
            'turno_nombre': null,
            'supervisor_nombre': null,
            'sync_status': 'pending',
        };

        result.add(BitacoraEntry.fromLocalDb(map));
        }

        return result;
    }

      /// 🧹 Limpia todos los registros pendientes de la cola local.
  /// Úsalo solo como herramienta de mantenimiento / depuración.
    Future<void> clearPendientes() async {
        final db = await _database;
        await db.delete(_pendingTable);
    }


}
