import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/bitacora_entry.dart';

class BitacoraLocalDb {
    static final BitacoraLocalDb _instance = BitacoraLocalDb._internal();
    factory BitacoraLocalDb() => _instance;
    BitacoraLocalDb._internal();

    Database? _db;

    Future<Database> get database async {
        if (_db != null) return _db!;
        _db = await _initDb();
        return _db!;
    }

    Future<Database> _initDb() async {
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, 'bitacora_local.db');

        return openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
            await db.execute('''
            CREATE TABLE bitacora_local (
                local_id INTEGER PRIMARY KEY AUTOINCREMENT,
                id INTEGER,
                num_asn TEXT,
                npi TEXT,
                estatus_aprobacion TEXT,
                placa TEXT,
                origen TEXT,
                destino TEXT,
                rampa TEXT,
                estado TEXT,
                fecha TEXT,
                hora_llegada TEXT,
                hora_salida TEXT,
                cantidad_tarimas INTEGER,
                id_turno INTEGER,
                id_transp INTEGER,
                id_supervisor INTEGER,
                turno_nombre TEXT,
                supervisor_nombre TEXT,
                sync_status TEXT
            )
            ''');
        },
        );
    }

    /// 👉 Lista completa (para mostrar en la UI)
    Future<List<BitacoraEntry>> obtenerTodos() async {
        final db = await database;
        final res = await db.query(
        'bitacora_local',
        orderBy: 'fecha DESC, local_id DESC',
        );
        return res.map((m) => BitacoraEntry.fromLocalDb(m)).toList();
    }

    /// 👉 Insertar un registro local (pending por default)
    Future<int> insertar(BitacoraEntry entry, {String status = 'pending'}) async {
        final db = await database;
        return await db.insert(
        'bitacora_local',
        entry.toLocalDbMap(forcedStatus: status),
        conflictAlgorithm: ConflictAlgorithm.replace,
        );
    }

    /// 👉 Reemplazar registros sincronizados por lo que venga del servidor.
    ///     Mantiene los registros pending/error.
    Future<void> reemplazarSynced(List<BitacoraEntry> remotos) async {
        final db = await database;

        await db.transaction((txn) async {
        // Borramos solo los que ya están sincronizados
        await txn.delete(
            'bitacora_local',
            where: 'sync_status IS NULL OR sync_status = ?',
            whereArgs: ['synced'],
        );

        // Insertamos los del servidor como synced
        for (final e in remotos) {
            await txn.insert(
            'bitacora_local',
            e.toLocalDbMap(forcedStatus: 'synced'),
            conflictAlgorithm: ConflictAlgorithm.replace,
            );
        }
        });
    }

    /// 👉 Registros pendientes (raw) para poder leer el local_id
    Future<List<Map<String, dynamic>>> obtenerPendientesRaw() async {
        final db = await database;
        final res = await db.query(
        'bitacora_local',
        where: 'sync_status = ?',
        whereArgs: ['pending'],
        );
        return res;
    }

    Future<void> actualizarSyncStatus(int localId, String status) async {
        final db = await database;
        await db.update(
        'bitacora_local',
        {'sync_status': status},
        where: 'local_id = ?',
        whereArgs: [localId],
        );
    }
}
