class NotificationItem {
    final int id;
    final int userId;
    final String titulo;
    final String? mensaje;
    final String tipo;
    final bool leida;
    final String? modelo;
    final int? modeloId;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    NotificationItem({
        required this.id,
        required this.userId,
        required this.titulo,
        this.mensaje,
        required this.tipo,
        required this.leida,
        this.modelo,
        this.modeloId,
        this.createdAt,
        this.updatedAt,
    });

    factory NotificationItem.fromJson(Map<String, dynamic> json) {
        return NotificationItem(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        titulo: json['titulo'] as String,
        mensaje: json['mensaje'] as String?,
        tipo: json['tipo'] as String? ?? 'info',
        leida: (json['leida'] is bool)
            ? json['leida'] as bool
            : (json['leida'] == 1 || json['leida'] == '1'),
        modelo: json['modelo'] as String?,
        modeloId: json['modelo_id'] != null
            ? int.tryParse(json['modelo_id'].toString())
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
        );
    }
}
