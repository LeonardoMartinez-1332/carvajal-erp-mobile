class TransporteOption {
    final int id;
    final String nombre;
    final int? turnoId;
    final String? turno;

    TransporteOption({
        required this.id,
        required this.nombre,
        this.turnoId,
        this.turno,
    });

    factory TransporteOption.fromJson(Map<String, dynamic> json) {
        return TransporteOption(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        turnoId: json['turno_id'] as int?,
        turno: json['turno'] as String?,
        );
    }
}
