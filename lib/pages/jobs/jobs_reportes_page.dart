import 'package:flutter/material.dart';

import 'package:carvajal_erp/data/jobs_repository.dart';
import 'package:carvajal_erp/models/ti_directa_resumen.dart';

class JobsReportesPage extends StatefulWidget {
    const JobsReportesPage({super.key});

    @override
    State<JobsReportesPage> createState() => _JobsReportesPageState();
}

class _JobsReportesPageState extends State<JobsReportesPage> {
    final JobsRepository _repo = JobsRepository();

    bool _loading = true;
    String? _error;

    int _tiHoy = 0;
    int _tiSemana = 0;

    String _almacenOrigenTop = '-';
    int _almacenOrigenCount = 0;

    String _almacenDestinoTop = '-';
    int _almacenDestinoCount = 0;

    @override
    void initState() {
        super.initState();
        _cargarKpis();
    }

    Future<void> _cargarKpis() async {
        try {
        final tis = await _repo.obtenerHistorialTi();

        if (!mounted) return;

        _calcularKpis(tis);
        setState(() => _loading = false);
        } catch (e) {
        if (!mounted) return;
        setState(() {
            _error = e.toString();
            _loading = false;
        });
        }
    }

    void _calcularKpis(List<TiDirectaResumen> tis) {
        final ahora = DateTime.now();
        final hoy = DateTime(ahora.year, ahora.month, ahora.day);

        int tiHoy = 0;
        int tiSemana = 0;

        final Map<String, int> origenCount = {};
        final Map<String, int> destinoCount = {};

        for (final ti in tis) {
        final fecha = ti.fecha;
        if (fecha == null) continue;

        final soloFecha = DateTime(fecha.year, fecha.month, fecha.day);
        final diff = hoy.difference(soloFecha).inDays;

        // Hoy
        if (diff == 0) {
            tiHoy++;
        }

        // Últimos 7 días (incluye hoy)
        if (diff >= 0 && diff <= 6) {
            tiSemana++;
        }

        // Conteo por almacén origen
        final origen = ti.almacenOrigen ?? '-';
        origenCount[origen] = (origenCount[origen] ?? 0) + 1;

        // Conteo por almacén destino
        final destino = ti.almacenDestino ?? '-';
        destinoCount[destino] = (destinoCount[destino] ?? 0) + 1;
        }

        String origenTop = '-';
        int origenTopCount = 0;

        origenCount.forEach((almacen, total) {
        if (total > origenTopCount) {
            origenTopCount = total;
            origenTop = almacen;
        }
        });

        String destinoTop = '-';
        int destinoTopCount = 0;

        destinoCount.forEach((almacen, total) {
        if (total > destinoTopCount) {
            destinoTopCount = total;
            destinoTop = almacen;
        }
        });

        _tiHoy = tiHoy;
        _tiSemana = tiSemana;
        _almacenOrigenTop = origenTop;
        _almacenOrigenCount = origenTopCount;
        _almacenDestinoTop = destinoTop;
        _almacenDestinoCount = destinoTopCount;
    }

    @override
    Widget build(BuildContext context) {
        const barColor = Color(0xFF004D40);

        if (_loading) {
        return Scaffold(
            appBar: AppBar(
            backgroundColor: barColor,
            foregroundColor: Colors.white,
            title: const Text('Reportes Jobs'),
            ),
            body: const Center(
            child: CircularProgressIndicator(),
            ),
        );
        }

        if (_error != null) {
        return Scaffold(
            appBar: AppBar(
            backgroundColor: barColor,
            foregroundColor: Colors.white,
            title: const Text('Reportes Jobs'),
            ),
            body: Center(
            child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                'Error al cargar KPIs:\n$_error',
                textAlign: TextAlign.center,
                ),
            ),
            ),
        );
        }

        return Scaffold(
        appBar: AppBar(
            backgroundColor: barColor,
            foregroundColor: Colors.white,
            title: const Text('Reportes Jobs'),
        ),
        body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
            const Text(
                'Mini KPIs de transferencias',
                style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                ),
            ),
            const SizedBox(height: 4),
            Text(
                'Vista rápida de cómo se han movido las TI en el almacén.',
                style: TextStyle(
                color: Colors.blueGrey[600],
                ),
            ),
            const SizedBox(height: 18),

            // Grid responsivo
            LayoutBuilder(
                builder: (context, c) {
                final w = c.maxWidth;
                final cols = w >= 1100
                    ? 2
                    : 1; // 2 columnas en escritorio, 1 en pantallas chicas

                return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 3.3,
                    children: [
                    JobsKpiCard(
                        icon: Icons.event_available,
                        iconColor: const Color(0xFF00897B),
                        title: 'TI de hoy',
                        value: '$_tiHoy',
                        subtitle: 'Total emitidas en el día',
                        accentColor: const Color(0xFF00897B),
                    ),
                    JobsKpiCard(
                        icon: Icons.view_week_rounded,
                        iconColor: const Color(0xFF7B1FA2),
                        title: 'Esta semana',
                        value: '$_tiSemana',
                        subtitle: 'TI generadas en los últimos 7 días',
                        accentColor: const Color(0xFF7B1FA2),
                    ),
                    JobsKpiCard(
                        icon: Icons.store_mall_directory_outlined,
                        iconColor: const Color(0xFF1976D2),
                        title: 'Almacén origen Top',
                        value: _almacenOrigenTop,
                        subtitle:
                            _almacenOrigenCount > 0 ? '$_almacenOrigenCount TI emitidas' : 'Sin datos',
                        accentColor: const Color(0xFF1976D2),
                    ),
                    JobsKpiCard(
                        icon: Icons.local_shipping_rounded,
                        iconColor: const Color(0xFFD81B60),
                        title: 'Almacén destino Top',
                        value: _almacenDestinoTop,
                        subtitle: _almacenDestinoCount > 0
                            ? '$_almacenDestinoCount TI recibidas'
                            : 'Sin datos',
                        accentColor: const Color(0xFFD81B60),
                    ),
                    ],
                );
                },
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Row(
                children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(
                    'Por ahora los valores se calculan con el historial local. '
                    'Después los conectamos al backend para mostrar datos por fecha, almacén, etc.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey[600],
                    ),
                    ),
                ),
                ],
            ),
            ],
        ),
        );
    }
}

class JobsKpiCard extends StatelessWidget {
    const JobsKpiCard({
        super.key,
        required this.icon,
        required this.iconColor,
        required this.title,
        required this.value,
        required this.subtitle,
        required this.accentColor,
    });

    final IconData icon;
    final Color iconColor;
    final String title;
    final String value;
    final String subtitle;
    final Color accentColor;

    @override
    Widget build(BuildContext context) {
        return Material(
        elevation: 3,
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
            // Futuro: abrir detalle / gráfico
            },
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                    children: [
                    CircleAvatar(
                        radius: 18,
                        backgroundColor: iconColor.withOpacity(.10),
                        child: Icon(icon, color: iconColor),
                    ),
                    const SizedBox(width: 10),
                    Text(
                        title,
                        style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        ),
                    ),
                    ],
                ),
                const SizedBox(height: 10),
                Text(
                    value,
                    style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    ),
                ),
                const SizedBox(height: 4),
                Container(
                    height: 2.5,
                    width: 42,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(999),
                    ),
                ),
                Text(
                    subtitle,
                    style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey[600],
                    ),
                ),
                ],
            ),
            ),
        ),
        );
    }
}
