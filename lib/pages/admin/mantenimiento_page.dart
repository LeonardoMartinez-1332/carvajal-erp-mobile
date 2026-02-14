import 'package:flutter/material.dart';

import '../../widgets/ui_bits.dart'; // GradientBackground, SectionCard

class AdminMantenimientoPage extends StatefulWidget {
    const AdminMantenimientoPage({super.key});

    @override
    State<AdminMantenimientoPage> createState() =>
        _AdminMantenimientoPageState();
}

class _AdminMantenimientoPageState extends State<AdminMantenimientoPage> {
  // Mock de últimos procesos
    DateTime? _ultimoBackup;
    DateTime? _ultimaLimpieza;
    DateTime? _ultimoJob;

    bool _backupEnProgreso = false;
    bool _limpiezaEnProgreso = false;
    bool _jobEnProgreso = false;

    String _retencionDias = '30 días';
    bool _autoBackupNocturno = true;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFFD32F2F),
            title: const Text('Respaldos & mantenimiento'),
        ),
        body: GradientBackground(
            child: SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const SectionCard(
                        title: 'Respaldos & mantenimiento',
                        subtitle: 'Backups • Limpieza • Jobs',
                        ),
                        const SizedBox(height: 16),

                        // 🔹 Resumen
                        Row(
                        children: [
                            Expanded(
                            child: _ResumenCard(
                                title: 'Último backup',
                                icon: Icons.storage_outlined,
                                color: Colors.red.shade700,
                                value: _ultimoBackup != null
                                    ? _fmtFecha(_ultimoBackup!)
                                    : 'Sin ejecutar',
                                hint: 'Base de datos ERP + catálogos',
                            ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                            child: _ResumenCard(
                                title: 'Limpieza',
                                icon: Icons.cleaning_services_outlined,
                                color: Colors.blueGrey,
                                value: _ultimaLimpieza != null
                                    ? _fmtFecha(_ultimaLimpieza!)
                                    : 'Sin ejecutar',
                                hint: 'Logs, auditoría antigua, jobs viejos',
                            ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                            child: _ResumenCard(
                                title: 'Jobs nocturnos',
                                icon: Icons.schedule_outlined,
                                color: Colors.deepOrange,
                                value: _ultimoJob != null
                                    ? _fmtFecha(_ultimoJob!)
                                    : 'Sin ejecutar',
                                hint: 'Procesos automáticos de TI / cierres',
                            ),
                            ),
                        ],
                        ),

                        const SizedBox(height: 16),

                        // 🔹 Backups
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
                                    Icon(Icons.backup_outlined,
                                        color: Colors.redAccent),
                                    SizedBox(width: 8),
                                    Text(
                                    'Respaldos',
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
                                'Estos controles son de demo. En producción se conectan al módulo real de backups.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                children: [
                                    Expanded(
                                    child: InputDecorator(
                                        decoration: InputDecoration(
                                        labelText: 'Retención de respaldos',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                        ),
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                        ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                            value: _retencionDias,
                                            isDense: true,
                                            isExpanded: true,
                                            items: const [
                                            '7 días',
                                            '15 días',
                                            '30 días',
                                            '60 días',
                                            ].map(
                                            (e) => DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                            ),
                                            ).toList(),
                                            onChanged: (v) {
                                            if (v == null) return;
                                            setState(() => _retencionDias = v);
                                            },
                                        ),
                                        ),
                                    ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                    child: SwitchListTile(
                                        title: const Text('Backup nocturno'),
                                        subtitle: const Text(
                                            'Ejecución automática 2:00 a.m.'),
                                        value: _autoBackupNocturno,
                                        onChanged: (v) {
                                        setState(
                                            () => _autoBackupNocturno = v);
                                        },
                                    ),
                                    ),
                                ],
                                ),
                                const SizedBox(height: 16),
                                Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.icon(
                                    onPressed: _backupEnProgreso
                                        ? null
                                        : () async {
                                            setState(
                                                () => _backupEnProgreso = true);
                                            await Future.delayed(
                                                const Duration(seconds: 1));
                                            setState(() {
                                            _backupEnProgreso = false;
                                            _ultimoBackup = DateTime.now();
                                            });
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                'Backup ejecutado (mock).',
                                                ),
                                            ),
                                            );
                                        },
                                    icon: _backupEnProgreso
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            ),
                                        )
                                        : const Icon(Icons.play_arrow),
                                    label: Text(
                                    _backupEnProgreso
                                        ? 'Ejecutando...'
                                        : 'Ejecutar backup ahora',
                                    ),
                                ),
                                ),
                            ],
                            ),
                        ),
                        ),

                        const SizedBox(height: 16),

                        // 🔹 Limpieza
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
                                    Icon(Icons.cleaning_services_outlined,
                                        color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text(
                                    'Limpieza',
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
                                'Acciones de mantenimiento para mantener liviano el ERP.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                    _ActionChipButton(
                                    icon: Icons.delete_sweep_outlined,
                                    label: 'Limpiar logs antiguos',
                                    onTap: _limpiezaEnProgreso
                                        ? null
                                        : () async {
                                            setState(() =>
                                                _limpiezaEnProgreso = true);
                                            await Future.delayed(
                                                const Duration(seconds: 1),
                                            );
                                            setState(() {
                                                _limpiezaEnProgreso = false;
                                                _ultimaLimpieza = DateTime.now();
                                            });
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                const SnackBar(
                                                content: Text(
                                                    'Limpieza de logs ejecutada (mock).',
                                                ),
                                                ),
                                            );
                                            },
                                    ),
                                    _ActionChipButton(
                                    icon: Icons.archive_outlined,
                                    label: 'Archivar auditoría > 6 meses',
                                    onTap: _limpiezaEnProgreso
                                        ? null
                                        : () async {
                                            setState(() =>
                                                _limpiezaEnProgreso = true);
                                            await Future.delayed(
                                                const Duration(seconds: 1),
                                            );
                                            setState(() {
                                                _limpiezaEnProgreso = false;
                                                _ultimaLimpieza = DateTime.now();
                                            });
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                const SnackBar(
                                                content: Text(
                                                    'Auditoría archivada (mock).',
                                                ),
                                                ),
                                            );
                                            },
                                    ),
                                    _ActionChipButton(
                                    icon: Icons.replay_circle_filled_outlined,
                                    label: 'Reindexar catálogos',
                                    onTap: _limpiezaEnProgreso
                                        ? null
                                        : () async {
                                            setState(() =>
                                                _limpiezaEnProgreso = true);
                                            await Future.delayed(
                                                const Duration(seconds: 1),
                                            );
                                            setState(() {
                                                _limpiezaEnProgreso = false;
                                                _ultimaLimpieza = DateTime.now();
                                            });
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                const SnackBar(
                                                content: Text(
                                                    'Reindexación ejecutada (mock).',
                                                ),
                                                ),
                                            );
                                            },
                                    ),
                                ],
                                ),
                            ],
                            ),
                        ),
                        ),

                        const SizedBox(height: 16),

                        // 🔹 Jobs
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
                                    Icon(Icons.playlist_play_outlined,
                                        color: Colors.deepOrange),
                                    SizedBox(width: 8),
                                    Text(
                                    'Jobs / procesos programados',
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
                                'Ejemplo de jobs: cierre diario de inventarios, consolidación de OT, actualización de KPIs, etc.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                ),
                                ),
                                const SizedBox(height: 12),
                                _JobRow(
                                name: 'Cierre diario de inventarios',
                                schedule: 'Todos los días · 23:30',
                                status: _ultimoJob != null
                                    ? 'Última ejecución: ${_fmtFecha(_ultimoJob!)}'
                                    : 'Pendiente de primera ejecución',
                                ),
                                const SizedBox(height: 8),
                                const _JobRow(
                                name: 'Actualización de KPIs',
                                schedule: 'Cada 2 horas',
                                status:
                                    'Mock • en producción vendrá del backend',
                                ),
                                const SizedBox(height: 16),
                                Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                    onPressed: _jobEnProgreso
                                        ? null
                                        : () async {
                                            setState(() => _jobEnProgreso = true);
                                            await Future.delayed(
                                            const Duration(seconds: 1),
                                            );
                                            setState(() {
                                            _jobEnProgreso = false;
                                            _ultimoJob = DateTime.now();
                                            });
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                'Jobs lanzados manualmente (mock).',
                                                ),
                                            ),
                                            );
                                        },
                                    icon: _jobEnProgreso
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            ),
                                        )
                                        : const Icon(Icons.play_arrow),
                                    label: Text(
                                    _jobEnProgreso
                                        ? 'Ejecutando...'
                                        : 'Forzar ejecución de jobs',
                                    ),
                                ),
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

    String _fmtFecha(DateTime dt) {
        final d = dt.day.toString().padLeft(2, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final h = dt.hour.toString().padLeft(2, '0');
        final min = dt.minute.toString().padLeft(2, '0');
        return '$d/$m · $h:$min';
    }
}

// ╔══════════════ Widgets auxiliares ══════════════╗

class _ResumenCard extends StatelessWidget {
    final String title;
    final IconData icon;
    final Color color;
    final String value;
    final String hint;

    const _ResumenCard({
        required this.title,
        required this.icon,
        required this.color,
        required this.value,
        required this.hint,
    });

    @override
    Widget build(BuildContext context) {
        return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 6),
                    Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                    ),
                    ),
                ],
                ),
                const SizedBox(height: 12),
                Text(
                value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                ),
                ),
                const SizedBox(height: 4),
                Text(
                hint,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                ),
                ),
            ],
            ),
        ),
        );
    }
}

class _ActionChipButton extends StatelessWidget {
    final IconData icon;
    final String label;
    final VoidCallback? onTap;

    const _ActionChipButton({
        required this.icon,
        required this.label,
        required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        final enabled = onTap != null;

        return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: enabled ? Colors.redAccent : Colors.grey.shade400,
            ),
            ),
            child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                Icon(
                icon,
                size: 18,
                color: enabled ? Colors.redAccent : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                label,
                style: TextStyle(
                    fontSize: 12,
                    color: enabled ? Colors.redAccent : Colors.grey.shade600,
                ),
                ),
            ],
            ),
        ),
        );
    }
}

class _JobRow extends StatelessWidget {
    final String name;
    final String schedule;
    final String status;

    const _JobRow({
        required this.name,
        required this.schedule,
        required this.status,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
            children: [
            const Icon(Icons.task_alt_outlined, size: 18),
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
                    schedule,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                    ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                    status,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                    ),
                    ),
                ],
                ),
            ),
            ],
        ),
        );
    }
}
