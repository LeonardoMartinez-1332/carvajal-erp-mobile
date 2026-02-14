class UnlockRequest {
    final int id;
    final int usuarioId;
    final String email;
    final String motivo;
    final String status;
    final DateTime createdAt;   // 👈 no-null
    final DateTime updatedAt;   // 👈 no-null

    // Datos opcionales del usuario relacionado
    final int? usuarioDbId;
    final String? usuarioNombre;
    final String? usuarioUsername;
    final bool? usuarioBloqueado;

    UnlockRequest({
        required this.id,
        required this.usuarioId,
        required this.email,
        required this.motivo,
        required this.status,
        required this.createdAt,
        required this.updatedAt,
        this.usuarioDbId,
        this.usuarioNombre,
        this.usuarioUsername,
        this.usuarioBloqueado,
    });

    /// 🔁 copyWith para poder actualizar solo el status en la lista
    UnlockRequest copyWith({
        int? id,
        int? usuarioId,
        String? email,
        String? motivo,
        String? status,
        DateTime? createdAt,
        DateTime? updatedAt,
        int? usuarioDbId,
        String? usuarioNombre,
        String? usuarioUsername,
        bool? usuarioBloqueado,
    }) {
        return UnlockRequest(
        id: id ?? this.id,
        usuarioId: usuarioId ?? this.usuarioId,
        email: email ?? this.email,
        motivo: motivo ?? this.motivo,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        usuarioDbId: usuarioDbId ?? this.usuarioDbId,
        usuarioNombre: usuarioNombre ?? this.usuarioNombre,
        usuarioUsername: usuarioUsername ?? this.usuarioUsername,
        usuarioBloqueado: usuarioBloqueado ?? this.usuarioBloqueado,
        );
    }

    factory UnlockRequest.fromJson(Map<String, dynamic> json) {
        final usuario = json['usuario'] as Map<String, dynamic>?;

        bool? bloqueado;
        if (usuario != null) {
        final raw = usuario['bloqueado'];
        if (raw is bool) {
            bloqueado = raw;
        } else if (raw is int) {
            bloqueado = raw == 1;
        } else if (raw is String) {
            bloqueado = raw == '1' || raw.toLowerCase() == 'true';
        }
        }

        DateTime _parse(dynamic v) {
        if (v is String && v.isNotEmpty) {
            return DateTime.parse(v);
        }
        // Si viene null/vacío, ponemos ahora para no crashear
        return DateTime.now();
        }

        final created = _parse(json['created_at']);
        final updated = json['updated_at'] != null
            ? _parse(json['updated_at'])
            : created;

        return UnlockRequest(
        id: json['id'] as int,
        usuarioId: json['usuario_id'] as int,
        email: (json['email'] ?? '') as String,
        motivo: (json['motivo'] ?? '') as String,
        status: (json['status'] ?? '') as String,
        createdAt: created,
        updatedAt: updated,
        usuarioDbId: usuario != null ? usuario['id'] as int? : null,
        usuarioNombre: usuario != null ? usuario['nombre'] as String? : null,
        usuarioUsername: usuario != null ? usuario['usuario'] as String? : null,
        usuarioBloqueado: bloqueado,
        );
    }

    Map<String, dynamic> toJson() {
        return {
        'id': id,
        'usuario_id': usuarioId,
        'email': email,
        'motivo': motivo,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'usuario': {
            'id': usuarioDbId,
            'nombre': usuarioNombre,
            'usuario': usuarioUsername,
            'bloqueado': usuarioBloqueado,
        },
        };
    }
}
