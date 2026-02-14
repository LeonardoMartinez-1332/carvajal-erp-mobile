class BitacoraEntry {
    final int id;

    // TI / FI real (puede venir vacío en pendientes)
    final String numAsn;

    // 🔹 Nuevo: NPI (número de pedido interno)
    final String? npi;

    // 🔹 Nuevo: estatus de aprobación (Pendiente / Aprobado / Rechazado)
    final String? estatusAprobacion;

    // Datos principales
    final String? placa;
    final String origen;
    final String destino;
    final String? rampa;
    final String estado;
    final String fecha;
    final String? horaLlegada;
    final String? horaSalida;
    final int cantidadTarimas;

    // Relación (solo IDs vienen en show/store/update)
    final int? idTurno;
    final int? idTransp;
    final int? idSupervisor;

    // Nombres "bonitos" para mostrar
    final String? turnoNombre;
    final String? supervisorNombre;

    // 🔹 NUEVO: estado de sincronización local
    // null / 'synced' / 'pending' / 'error'
    final String? syncStatus;

    BitacoraEntry({
        required this.id,
        required this.numAsn,
        this.npi,
        this.estatusAprobacion,
        this.placa,
        required this.origen,
        required this.destino,
        this.rampa,
        required this.estado,
        required this.fecha,
        this.horaLlegada,
        this.horaSalida,
        required this.cantidadTarimas,
        this.idTurno,
        this.idTransp,
        this.idSupervisor,
        this.turnoNombre,
        this.supervisorNombre,
        this.syncStatus, // 👈 opcional, no rompe lo demás
    });

    factory BitacoraEntry.fromJson(Map<String, dynamic> json) {
        return BitacoraEntry(
        id: json['id'] as int,
        numAsn: (json['num_asn'] ?? '').toString(),
        npi: json['npi']?.toString(),
        estatusAprobacion: json['estatus_aprobacion']?.toString(),
        placa: json['placa']?.toString() ??
            (json['camion'] != null
                ? json['camion']['nom_linea']?.toString()
                : null),
        origen: (json['origen'] ?? '').toString(),
        destino: (json['destino'] ?? '').toString(),
        rampa: json['rampa']?.toString(),
        estado: (json['estado'] ?? '').toString(),
        fecha: (json['fecha'] ?? '').toString(),
        horaLlegada: json['hora_llegada']?.toString(),
        horaSalida: json['hora_salida']?.toString(),
        cantidadTarimas: (json['cantidad_tarimas'] ?? 0) is int
            ? json['cantidad_tarimas']
            : int.tryParse(json['cantidad_tarimas'].toString()) ?? 0,
        idTurno: json['id_turno'] as int?,
        idTransp: json['id_transp'] as int?,
        idSupervisor: json['id_supervisor'] as int?,
        turnoNombre: json['turno'] is String
            ? json['turno']
            : (json['turno'] != null
                ? json['turno']['nombre']?.toString()
                : null),
        supervisorNombre: json['supervisor'] is String
            ? json['supervisor']
            : (json['supervisor'] != null
                ? json['supervisor']['nombre']?.toString()
                : null),
        // syncStatus lo dejamos null por defecto para cosas que vienen del servidor
        );
    }

    Map<String, dynamic> toJsonForCreateOrUpdate() {
        return {
        'fecha': fecha,
        'hora_llegada': horaLlegada,
        'id_turno': idTurno,
        'id_transp': idTransp,
        'origen': origen,
        'destino': destino,
        'num_asn': numAsn,
        'rampa': rampa,
        'estado': estado,
        'id_supervisor': idSupervisor,
        'cantidad_tarimas': cantidadTarimas,
        'hora_salida': horaSalida,
        };
    }

    // 🔹 NUEVO: cómo guardarlo en BD local (offline)
    Map<String, dynamic> toLocalDbMap({String? forcedStatus}) {
        return {
        // Este "id" es el id remoto si existe (o 0 si todavía no lo tienes)
        'id': id,
        'num_asn': numAsn,
        'npi': npi,
        'estatus_aprobacion': estatusAprobacion,
        'placa': placa,
        'origen': origen,
        'destino': destino,
        'rampa': rampa,
        'estado': estado,
        'fecha': fecha,
        'hora_llegada': horaLlegada,
        'hora_salida': horaSalida,
        'cantidad_tarimas': cantidadTarimas,
        'id_turno': idTurno,
        'id_transp': idTransp,
        'id_supervisor': idSupervisor,
        'turno_nombre': turnoNombre,
        'supervisor_nombre': supervisorNombre,
        'sync_status': forcedStatus ?? syncStatus ?? 'pending',
        };
    }

    // 🔹 NUEVO: cómo reconstruirlo desde BD local
    factory BitacoraEntry.fromLocalDb(Map<String, dynamic> json) {
        return BitacoraEntry(
        id: (json['id'] ?? 0) as int,
        numAsn: (json['num_asn'] ?? '').toString(),
        npi: json['npi']?.toString(),
        estatusAprobacion: json['estatus_aprobacion']?.toString(),
        placa: json['placa']?.toString(),
        origen: (json['origen'] ?? '').toString(),
        destino: (json['destino'] ?? '').toString(),
        rampa: json['rampa']?.toString(),
        estado: (json['estado'] ?? '').toString(),
        fecha: (json['fecha'] ?? '').toString(),
        horaLlegada: json['hora_llegada']?.toString(),
        horaSalida: json['hora_salida']?.toString(),
        cantidadTarimas: (json['cantidad_tarimas'] ?? 0) is int
            ? json['cantidad_tarimas']
            : int.tryParse(json['cantidad_tarimas'].toString()) ?? 0,
        idTurno: json['id_turno'] as int?,
        idTransp: json['id_transp'] as int?,
        idSupervisor: json['id_supervisor'] as int?,
        turnoNombre: json['turno_nombre']?.toString(),
        supervisorNombre: json['supervisor_nombre']?.toString(),
        syncStatus: json['sync_status']?.toString(),
        );
    }
}
