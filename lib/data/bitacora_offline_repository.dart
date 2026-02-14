import '../models/bitacora_entry.dart';
import 'bitacora_local_db.dart';
import 'bitacora_repository.dart';

class BitacoraOfflineRepository {
    final BitacoraLocalDb _localDb = BitacoraLocalDb();
    final BitacoraRepository _remoteRepo;

    BitacoraOfflineRepository(this._remoteRepo);

    /// 👉 Lectura: siempre desde la BD local
    Future<List<BitacoraEntry>> obtenerTodos() async {
        return _localDb.obtenerTodos();
    }

    /// 👉 Guardar un registro nuevo en local como pending
    Future<void> agregarLocal(BitacoraEntry entry) async {
        await _localDb.insertar(entry, status: 'pending');
    }

    /// 👉 Actualizar cache local con lo que venga del servidor (modo online)
    ///     (llamado desde BitacoraPage._reload)
    Future<void> reemplazarDesdeServidor(List<BitacoraEntry> remotos) async {
        await _localDb.reemplazarSynced(remotos);
    }

    /// 👉 Enviar todos los registros pending al backend
    Future<void> sincronizarPendientes() async {
        final pendientesRaw = await _localDb.obtenerPendientesRaw();

        for (final row in pendientesRaw) {
        final localId = row['local_id'] as int;
        final entry = BitacoraEntry.fromLocalDb(row);

        try {
            // 👇 IMPORTANTE: aquí usamos el método create del BitacoraRepository
            await _remoteRepo.create(
            origen: entry.origen,
            destino: entry.destino,
            rampa: entry.rampa,
            fecha: entry.fecha,
            horaLlegada: entry.horaLlegada,
            horaSalida: entry.horaSalida,
            idTurno: entry.idTurno ?? 0,
            idTransp: entry.idTransp ?? 0,
            cantidadTarimas: entry.cantidadTarimas,
            estado: entry.estado,
            );

            // Si no truena, marcamos como synced
            await _localDb.actualizarSyncStatus(localId, 'synced');
        } catch (_) {
            // Si truena, marcamos error para verlo en rojo en la UI
            await _localDb.actualizarSyncStatus(localId, 'error');
        }
        }
    }
}
