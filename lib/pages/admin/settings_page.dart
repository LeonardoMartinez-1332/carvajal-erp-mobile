import 'package:flutter/material.dart';

import '../../widgets/ui_bits.dart'; // GradientBackground, SectionCard

class AdminSettingsPage extends StatefulWidget {
    const AdminSettingsPage({super.key});

    @override
    State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
    bool _usoModoOscuro = false;
    bool _enviarCorreosAlertas = true;
    bool _bloquearMultiSesion = true;
    String _zonaHoraria = 'America/Mexico_City';
    String _lenguaje = 'Español (MX)';
    bool _wmsOnline = true;
    bool _erpOnline = true;
    bool _jobsActivo = true;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFF455A64),
            title: const Text('Configuración'),
        ),
        body: GradientBackground(
            child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Center(
                child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: SingleChildScrollView(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const SectionCard(
                        title: 'Configuración',
                        subtitle: 'Parámetros • Integraciones • ERP',
                        ),
                        const SizedBox(height: 16),

                        // 🔹 Parámetros generales
                        Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                children: const [
                                    Icon(Icons.tune, color: Colors.blueGrey),
                                    SizedBox(width: 8),
                                    Text(
                                    'Parámetros generales',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                    ),
                                    ),
                                ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),

                                Wrap(
                                spacing: 24,
                                runSpacing: 8,
                                children: [
                                    SizedBox(
                                    width: 260,
                                    child: _DropdownSetting(
                                        label: 'Zona horaria',
                                        value: _zonaHoraria,
                                        items: const [
                                        'America/Mexico_City',
                                        'America/Monterrey',
                                        'America/Bogota',
                                        'UTC',
                                        ],
                                        onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _zonaHoraria = v);
                                        },
                                    ),
                                    ),
                                    SizedBox(
                                    width: 260,
                                    child: _DropdownSetting(
                                        label: 'Lenguaje',
                                        value: _lenguaje,
                                        items: const [
                                        'Español (MX)',
                                        'Español (ES)',
                                        'Inglés',
                                        ],
                                        onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _lenguaje = v);
                                        },
                                    ),
                                    ),
                                ],
                                ),
                                const SizedBox(height: 12),

                                SwitchListTile(
                                title: const Text('Modo oscuro (próximamente)'),
                                subtitle: const Text(
                                    'Ajuste visual para el ERP en desktop y handheld',
                                ),
                                value: _usoModoOscuro,
                                onChanged: (v) {
                                    setState(() => _usoModoOscuro = v);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                        'El modo oscuro es solo visual por ahora (mock).',
                                        ),
                                    ),
                                    );
                                },
                                ),
                                SwitchListTile(
                                title: const Text('Enviar correos de alertas'),
                                subtitle: const Text(
                                    'Notificaciones críticas a supervisores / admins',
                                ),
                                value: _enviarCorreosAlertas,
                                onChanged: (v) {
                                    setState(() => _enviarCorreosAlertas = v);
                                },
                                ),
                                SwitchListTile(
                                title:
                                    const Text('Bloquear múltiples sesiones por usuario'),
                                subtitle: const Text(
                                    'Evita que un usuario tenga varias sesiones simultáneas',
                                ),
                                value: _bloquearMultiSesion,
                                onChanged: (v) {
                                    setState(() => _bloquearMultiSesion = v);
                                },
                                ),
                            ],
                            ),
                        ),
                        ),

                        const SizedBox(height: 16),

                        // 🔹 Integraciones
                        Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                children: const [
                                    Icon(Icons.hub_outlined, color: Colors.teal),
                                    SizedBox(width: 8),
                                    Text(
                                    'Integraciones',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                    ),
                                    ),
                                ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),

                                _IntegrationTile(
                                name: 'WMS',
                                description: 'Sincronización de inventarios y OT',
                                online: _wmsOnline,
                                onPing: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Ping WMS OK (mock)'),
                                    ),
                                    );
                                },
                                onToggle: (v) {
                                    setState(() => _wmsOnline = v);
                                },
                                ),
                                const SizedBox(height: 8),
                                _IntegrationTile(
                                name: 'ERP corporativo',
                                description: 'Interfase con facturación y contabilidad',
                                online: _erpOnline,
                                onPing: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Ping ERP OK (mock)'),
                                    ),
                                    );
                                },
                                onToggle: (v) {
                                    setState(() => _erpOnline = v);
                                },
                                ),
                                const SizedBox(height: 8),
                                _IntegrationTile(
                                name: 'Jobs / TI automatizadas',
                                description: 'Procesos nocturnos de carga y cierres',
                                online: _jobsActivo,
                                onPing: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Ping Jobs OK (mock)'),
                                    ),
                                    );
                                },
                                onToggle: (v) {
                                    setState(() => _jobsActivo = v);
                                },
                                ),
                            ],
                            ),
                        ),
                        ),

                        const SizedBox(height: 16),

                        // 🔹 Config ERP
                        Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                children: const [
                                    Icon(Icons.settings_suggest_outlined,
                                        color: Colors.indigo),
                                    SizedBox(width: 8),
                                    Text(
                                    'Configuración del ERP',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                    ),
                                    ),
                                ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),

                                const Text(
                                'Estos parámetros son de demo. En producción saldrán de la BD / API.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                ),
                                ),
                                const SizedBox(height: 12),

                                Wrap(
                                spacing: 24,
                                runSpacing: 12,
                                children: const [
                                    _TagChip(
                                    label: 'Modo: Offline-first',
                                    icon: Icons.cloud_off_outlined,
                                    ),
                                    _TagChip(
                                    label: 'Handheld: CD40 / Android',
                                    icon: Icons.qr_code_scanner_outlined,
                                    ),
                                    _TagChip(
                                    label: 'Versión backend: v1.0.0',
                                    icon: Icons.dns_outlined,
                                    ),
                                    _TagChip(
                                    label: 'Versión app: v0.9.5-beta',
                                    icon: Icons.phone_iphone,
                                    ),
                                ],
                                ),
                            ],
                            ),
                        ),
                        ),
                    ],
                    ),
                ),
                ),
            ),
            ),
        ),
        );
    }
}

class _DropdownSetting extends StatelessWidget {
    final String label;
    final String value;
    final List<String> items;
    final ValueChanged<String?> onChanged;

    const _DropdownSetting({
        required this.label,
        required this.value,
        required this.items,
        required this.onChanged,
    });

    @override
    Widget build(BuildContext context) {
        return InputDecorator(
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            items: items
                .map(
                    (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                    ),
                )
                .toList(),
            onChanged: onChanged,
            ),
        ),
        );
    }
}

class _IntegrationTile extends StatelessWidget {
    final String name;
    final String description;
    final bool online;
    final VoidCallback onPing;
    final ValueChanged<bool> onToggle;

    const _IntegrationTile({
        required this.name,
        required this.description,
        required this.online,
        required this.onPing,
        required this.onToggle,
    });

    @override
    Widget build(BuildContext context) {
        final color = online ? Colors.green : Colors.redAccent;

        return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.grey.shade50,
            border: Border.all(
            color: online ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
            children: [
            Icon(
                online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                    ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                    description,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                    ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                    online ? 'Estado: en línea' : 'Estado: desconectado',
                    style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                    ),
                    ),
                ],
                ),
            ),
            const SizedBox(width: 8),
            TextButton(
                onPressed: onPing,
                child: const Text('Probar'),
            ),
            Switch(
                value: online,
                onChanged: onToggle,
            ),
            ],
        ),
        );
    }
}

class _TagChip extends StatelessWidget {
    final String label;
    final IconData icon;

    const _TagChip({
        required this.label,
        required this.icon,
    });

    @override
    Widget build(BuildContext context) {
        return Chip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        );
    }
}
