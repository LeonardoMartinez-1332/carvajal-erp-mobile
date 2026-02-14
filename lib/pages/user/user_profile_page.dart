import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
    const UserProfilePage({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFF00897B),
            title: const Text('Mi perfil'),
        ),
        body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
            const SizedBox(height: 12),
            const Text(
                'Datos del usuario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
                decoration: InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
                ),
            ),
            const SizedBox(height: 16),
            const TextField(
                decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
                ),
            ),
            const SizedBox(height: 16),
            const Text(
                'Cambiar contraseña',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
                obscureText: true,
                decoration: InputDecoration(
                labelText: 'Contraseña actual',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
                ),
            ),
            const SizedBox(height: 16),
            const TextField(
                obscureText: true,
                decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: Icon(Icons.lock_reset),
                border: OutlineInputBorder(),
                ),
            ),
            const SizedBox(height: 16),
            const TextField(
                obscureText: true,
                decoration: InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                prefixIcon: Icon(Icons.check_circle_outline),
                border: OutlineInputBorder(),
                ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cambios guardados (simulado)')),
                );
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar cambios'),
            ),
            ],
        ),
        );
    }
}
