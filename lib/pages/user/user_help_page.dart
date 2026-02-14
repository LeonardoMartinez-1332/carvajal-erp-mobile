import 'package:flutter/material.dart';

class UserHelpPage extends StatelessWidget {
    const UserHelpPage({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFFF57C00),
            title: const Text('Centro de ayuda'),
        ),
        body: ListView(
            padding: const EdgeInsets.all(20),
            children: const [
            Text(
                'Guías rápidas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Cómo consultar productos\n• Cómo actualizar tu perfil\n• Qué hacer si olvidaste tu contraseña'),
            SizedBox(height: 24),
            Text(
                'Preguntas frecuentes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('¿Qué hago si no puedo acceder?\n— Intenta cerrar sesión y volver a iniciar.'),
            Text('¿Dónde reporto un error?\n— Usa el botón "Reportar incidencia" en el panel principal.'),
            SizedBox(height: 24),
            Text(
                'Contacto de soporte',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('📧 soporte@carvajal-erp.com\n📞 +52 81 0000 0000'),
            ],
        ),
        );
    }
}
