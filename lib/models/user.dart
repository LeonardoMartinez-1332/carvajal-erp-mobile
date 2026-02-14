class UserModel {
    final int id;
    final String name;
    final String email;
    final String role; // usuario | supervisor | superusuario | jobs

    const UserModel({
        required this.id,
        required this.name,
        required this.email,
        required this.role,
    });

    factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] is int
            ? map['id'] as int
            : int.tryParse(map['id']?.toString() ?? '') ?? 0,
        name: map['name']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        // 🔹 Normalizamos: null-safe, trim y lowercase
        role: (map['role'] ?? 'usuario').toString().trim().toLowerCase(),
    );

    // Helpers opcionales
    bool get isAdmin =>
        role == 'superusuario' || role == 'admin' || role == 'administrator';

    bool get isSupervisor => role == 'supervisor';

    bool get isJobs => role == 'jobs';
}
