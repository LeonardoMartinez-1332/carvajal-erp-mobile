class AdminUser {
    final int id;
    final String name;
    final String email;
    final String role;
    final bool activo;
    final DateTime? createdAt;
    final DateTime? lastLogin;

    AdminUser({
        required this.id,
        required this.name,
        required this.email,
        required this.role,
        required this.activo,
        this.createdAt,
        this.lastLogin,
    });

    factory AdminUser.fromJson(Map<String, dynamic> json) {
        final rawActivo = json['activo'];

        return AdminUser(
        id: json['id'] as int,
        // el backend manda 'nombre' y 'correo'
        name: (json['nombre'] ?? '') as String,
        email: (json['correo'] ?? '') as String,
        role: (json['role'] ?? '') as String,

        //convertir 1/0, true/false o '1'/'0' a bool
        activo: rawActivo == 1 ||
            rawActivo == true ||
            rawActivo == '1',

        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        lastLogin: json['last_login'] != null
            ? DateTime.tryParse(json['last_login'].toString())
            : null,
        );
    }
}
