import 'package:flutter/material.dart';

import '../../widgets/ui_bits.dart'; // GradientBackground, SectionCard

class AdminLogsPage extends StatefulWidget {
    const AdminLogsPage({super.key});

    @override
    State<AdminLogsPage> createState() => _AdminLogsPageState();
}

class _AdminLogsPageState extends State<AdminLogsPage> {
    final TextEditingController _searchCtrl = TextEditingController();

    String _filtroSeveridad = 'Todos';
    String _filtroModulo = 'Todos';

    // 🔹 Logs mock para la demo (luego se conectan al backend)
    final List<_LogItem> _logs = [
        _LogItem(
        fecha: DateTime(2025, 12, 1, 9, 32),
        usuario: 'fortino.s',
        rol: 'Supervisor',
        modulo: 'Inventarios',
        accion: 'Ajuste de inventario',
        detalle: 'PT 2864132399 · -120 cajas',
        severidad: _Severity.info,
        ),
        _LogItem(
        fecha: DateTime(2025, 12, 1, 9, 40),
        usuario: 'javier.p',
        rol: 'Admin',
        modulo: 'Jobs / TI',
        accion: 'TI aprobada',
        detalle: 'TI-12457 · 2 pallets FOAM CUP 32oz',
        severidad: _Severity.success,
        ),
        _LogItem(
        fecha: DateTime(2025, 12, 1, 10, 5),
        usuario: 'brenda.m',
        rol: 'Supervisor',
        modulo: 'Devoluciones',
        accion: 'Devolución registrada',
        detalle: 'Whataburger · 1 pallet en revisión',
        severidad: _Severity.warning,
        ),
        _LogItem(
        fecha: DateTime(2025, 12, 1, 10, 18),
        usuario: 'admin',
        rol: 'Superusuario',
        modulo: 'Seguridad',
        accion: 'Intento de login fallido',
        detalle: 'Usuario bloqueado tras 3 intentos',
        severidad: _Severity.critical,
        ),
        _LogItem(
        fecha: DateTime(2025, 12, 1, 10, 25),
        usuario: 'fortino.s',
        rol: 'Supervisor',
        modulo: 'Bitácora camiones',
        accion: 'Salida confirmada',
        detalle: 'Camión 879-TRX · salida 10:20',
        severidad: _Severity.success,
        ),
    ];

    @override
    void dispose() {
        _searchCtrl.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        // 🔎 Filtro local
        final filtroTexto = _searchCtrl.text.trim().toLowerCase();

        final filtrados = _logs.where((log) {
        final matchTexto = filtroTexto.isEmpty ||
            log.usuario.toLowerCase().contains(filtroTexto) ||
            log.modulo.toLowerCase().contains(filtroTexto) ||
            log.accion.toLowerCase().contains(filtroTexto) ||
            log.detalle.toLowerCase().contains(filtroTexto);

        final matchSeveridad = _filtroSeveridad == 'Todos' ||
            _filtroSeveridad == _severityLabel(log.severidad);

        final matchModulo =
            _filtroModulo == 'Todos' || _filtroModulo == log.modulo;

        return matchTexto && matchSeveridad && matchModulo;
        }).toList();

        return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFFFF9800),
            title: const Text('Auditoría y logs'),
        ),
        body: GradientBackground(
            child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const SectionCard(
                    title: 'Auditoría y logs',
                    subtitle: 'Trazabilidad • Acciones por usuario',
                ),
                const SizedBox(height: 16),

                // 🔝 Filtros
                Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                        SizedBox(
                            width: 260,
                            child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: 'Buscar por usuario, módulo o acción…',
                                border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                ),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                            ),
                            onChanged: (_) => setState(() {}),
                            ),
                        ),
                        _FiltroDropdown(
                            label: 'Severidad',
                            value: _filtroSeveridad,
                            items: const [
                            'Todos',
                            'Info',
                            'Éxito',
                            'Advertencia',
                            'Crítico',
                            ],
                            onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroSeveridad = v);
                            },
                        ),
                        _FiltroDropdown(
                            label: 'Módulo',
                            value: _filtroModulo,
                            items: const [
                            'Todos',
                            'Inventarios',
                            'Jobs / TI',
                            'Devoluciones',
                            'Seguridad',
                            'Bitácora camiones',
                            ],
                            onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroModulo = v);
                            },
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                            onPressed: () {
                            setState(() {
                                _searchCtrl.clear();
                                _filtroSeveridad = 'Todos';
                                _filtroModulo = 'Todos';
                            });
                            },
                            icon: const Icon(Icons.filter_alt_off_outlined),
                            label: const Text('Limpiar filtros'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                            onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                content: Text(
                                    'Exportar auditoría (pendiente conectar al backend)'),
                                ),
                            );
                            },
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Exportar'),
                        ),
                        ],
                    ),
                    ),
                ),
                const SizedBox(height: 16),

                // 🔻 Tabla de logs
                Expanded(
                    child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1300),
                        child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                Row(
                                children: [
                                    const Icon(Icons.event_note_outlined,
                                        size: 20, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    const Text(
                                    'Registro de eventos',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                    ),
                                    ),
                                    const Spacer(),
                                    Text(
                                    'Total: ${filtrados.length} eventos',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                    ),
                                    ),
                                ],
                                ),
                                const SizedBox(height: 8),
                                const Divider(height: 1),

                                const SizedBox(height: 4),
                                Expanded(
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                        headingRowHeight: 40,
                                        dataRowMinHeight: 40,
                                        dataRowMaxHeight: 60,
                                        columnSpacing: 20,
                                        columns: const [
                                        DataColumn(
                                            label: Text('Fecha / hora'),
                                        ),
                                        DataColumn(
                                            label: Text('Usuario'),
                                        ),
                                        DataColumn(
                                            label: Text('Rol'),
                                        ),
                                        DataColumn(
                                            label: Text('Módulo'),
                                        ),
                                        DataColumn(
                                            label: Text('Acción'),
                                        ),
                                        DataColumn(
                                            label: Text('Detalle'),
                                        ),
                                        DataColumn(
                                            label: Text('Severidad'),
                                        ),
                                        ],
                                        rows: List.generate(
                                        filtrados.length,
                                        (index) {
                                            final log = filtrados[index];
                                            final color =
                                                _rowColorForSeverity(log.severidad);

                                            return DataRow(
                                            // Coloreamos la fila según severidad
                                            color: MaterialStateProperty
                                                .resolveWith<Color?>(
                                                (states) => color,
                                            ),
                                            cells: [
                                                DataCell(
                                                Text(
                                                    _formatFecha(log.fecha),
                                                ),
                                                ),
                                                DataCell(Text(log.usuario)),
                                                DataCell(Text(log.rol)),
                                                DataCell(Text(log.modulo)),
                                                DataCell(Text(log.accion)),
                                                DataCell(
                                                SizedBox(
                                                    width: 260,
                                                    child: Text(
                                                    log.detalle,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    ),
                                                ),
                                                ),
                                                DataCell(
                                                _SeverityChip(
                                                    severity: log.severidad,
                                                ),
                                                ),
                                            ],
                                            );
                                        },
                                        ),
                                    ),
                                    ),
                                ),
                                ),

                                const SizedBox(height: 4),
                                const _LegendRow(),
                            ],
                            ),
                        ),
                        ),
                    ),
                    ),
                ),
                ],
            ),
            ),
        ),
        );
    }

    String _formatFecha(DateTime dt) {
        // hh:mm 24h, dd/MM
        final h =
            dt.hour.toString().padLeft(2, '0');
        final m =
            dt.minute.toString().padLeft(2, '0');
        final d =
            dt.day.toString().padLeft(2, '0');
        final mo =
            dt.month.toString().padLeft(2, '0');
        return '$d/$mo · $h:$m';
    }

    static String _severityLabel(_Severity s) {
        switch (s) {
        case _Severity.info:
            return 'Info';
        case _Severity.success:
            return 'Éxito';
        case _Severity.warning:
            return 'Advertencia';
        case _Severity.critical:
            return 'Crítico';
        }
    }

    Color? _rowColorForSeverity(_Severity s) {
        switch (s) {
        case _Severity.info:
            return Colors.blue.withOpacity(0.02);
        case _Severity.success:
            return Colors.green.withOpacity(0.03);
        case _Severity.warning:
            return Colors.orange.withOpacity(0.04);
        case _Severity.critical:
            return Colors.red.withOpacity(0.05);
        }
    }
}

// ╔══════════════ Helpers ══════════════╗

enum _Severity { info, success, warning, critical }

class _LogItem {
    final DateTime fecha;
    final String usuario;
    final String rol;
    final String modulo;
    final String accion;
    final String detalle;
    final _Severity severidad;

    _LogItem({
        required this.fecha,
        required this.usuario,
        required this.rol,
        required this.modulo,
        required this.accion,
        required this.detalle,
        required this.severidad,
    });
}

class _FiltroDropdown extends StatelessWidget {
    final String label;
    final String value;
    final List<String> items;
    final ValueChanged<String?> onChanged;

    const _FiltroDropdown({
        required this.label,
        required this.value,
        required this.items,
        required this.onChanged,
    });

    @override
    Widget build(BuildContext context) {
        return SizedBox(
        width: 170,
        child: InputDecorator(
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
                isDense: true,
                isExpanded: true,
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
        ),
        );
    }
}

class _SeverityChip extends StatelessWidget {
    final _Severity severity;

    const _SeverityChip({required this.severity});

    @override
    Widget build(BuildContext context) {
        late final Color color;
        late final String label;

        switch (severity) {
        case _Severity.info:
            color = Colors.blue;
            label = 'Info';
            break;
        case _Severity.success:
            color = Colors.green;
            label = 'Éxito';
            break;
        case _Severity.warning:
            color = Colors.orange;
            label = 'Advertencia';
            break;
        case _Severity.critical:
            color = Colors.red;
            label = 'Crítico';
            break;
        }

        return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            Icon(
                severity == _Severity.critical
                    ? Icons.error_outline
                    : severity == _Severity.warning
                        ? Icons.warning_amber_outlined
                        : severity == _Severity.success
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                size: 14,
                color: color,
            ),
            const SizedBox(width: 4),
            Text(
                label,
                style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.darken(),
                ),
            )
            ],
        ),
        );
    }
}

class _LegendRow extends StatelessWidget {
    const _LegendRow();

    @override
    Widget build(BuildContext context) {
        return Row(
        children: const [
            Text(
            'Leyenda: ',
            style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
            SizedBox(width: 8),
            _LegendDot(color: Colors.blue, label: 'Info'),
            SizedBox(width: 12),
            _LegendDot(color: Colors.green, label: 'Éxito'),
            SizedBox(width: 12),
            _LegendDot(color: Colors.orange, label: 'Advertencia'),
            SizedBox(width: 12),
            _LegendDot(color: Colors.red, label: 'Crítico'),
        ],
        );
    }
}

class _LegendDot extends StatelessWidget {
    final Color color;
    final String label;

    const _LegendDot({required this.color, required this.label});

    @override
    Widget build(BuildContext context) {
        return Row(
        children: [
            Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
            ),
            ),
            const SizedBox(width: 4),
            Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
            )
        ],
        );
    }
}

// Pequeña extensión para oscurecer un poco el texto del chip
extension on Color {
    Color darken([double amount = .1]) {
        assert(amount >= 0 && amount <= 1);
        final f = 1 - amount;
        return Color.fromARGB(
        alpha,
        (red * f).round(),
        (green * f).round(),
        (blue * f).round(),
        );
    }
}
