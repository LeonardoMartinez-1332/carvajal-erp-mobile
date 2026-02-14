class TurnoOption {
    final int id;
    final String nombre;

    TurnoOption({
        required this.id,
        required this.nombre,
    });

    factory TurnoOption.fromJson(Map<String, dynamic> json) {
        return TurnoOption(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        );
    }
}
