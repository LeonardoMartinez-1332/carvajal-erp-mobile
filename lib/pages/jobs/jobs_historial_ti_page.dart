import 'package:flutter/material.dart';

import 'package:carvajal_erp/data/jobs_repository.dart';
import 'package:carvajal_erp/models/ti_directa_resumen.dart';
import 'package:carvajal_erp/core/routes.dart';

class JobsHistorialTiPage extends StatefulWidget {
    const JobsHistorialTiPage({super.key});

    @override
    State<JobsHistorialTiPage> createState() => _JobsHistorialTiPageState();
}

class _JobsHistorialTiPageState extends State<JobsHistorialTiPage> {
    final JobsRepository _repo = JobsRepository();

    bool _loading = true;
    String? _error;

    /// Lista completa que viene del backend
    List<TiDirectaResumen> _allTis = [];

    /// Lista filtrada que mostramos en pantalla
    List<TiDirectaResumen> _tis = [];

    final TextEditingController _searchCtrl = TextEditingController();

    @override
    void initState() {
        super.initState();
        _cargarHistorial();
    }

    @override
    void dispose() {
        _searchCtrl.dispose();
        super.dispose();
    }

    Future<void> _cargarHistorial() async {
        try {
        final resultado = await _repo.obtenerHistorialTi();

        setState(() {
            _allTis = resultado;
            _tis = resultado; // al inicio se muestran todas
            _loading = false;
        });
        } catch (e) {
        setState(() {
            _error = e.toString();
            _loading = false;
        });
        }
    }

    String _formatearFecha(DateTime? fecha) {
        if (fecha == null) return '-';

        final f = fecha;
        final dia = f.day.toString().padLeft(2, '0');
        final mes = f.month.toString().padLeft(2, '0');
        final anio = f.year.toString();

        return '$dia/$mes/$anio';
    }

    /// Aplica filtro por folio TI (y opcionalmente por id interno)
    void _aplicarFiltro(String query) {
        final text = query.trim().toLowerCase();

        setState(() {
        if (text.isEmpty) {
            _tis = List.from(_allTis);
        } else {
            _tis = _allTis.where((ti) {
            final folio = ti.numTi.toLowerCase();
            final idInterno = ti.id.toString(); // por si quieres buscar por id
            return folio.contains(text) || idInterno.contains(text);
            }).toList();
        }
        });
    }

    @override
    Widget build(BuildContext context) {
        if (_loading) {
        return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
        );
        }

        if (_error != null) {
        return Scaffold(
            appBar: AppBar(title: const Text('Historial TI')),
            body: Center(
            child: Text(
                'Error al cargar historial:\n$_error',
                textAlign: TextAlign.center,
            ),
            ),
        );
        }

        return Scaffold(
        appBar: AppBar(title: const Text('Historial TI')),
        body: Column(
            children: [
            // === BUSCADOR ===
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                    hintText: 'Buscar por folio TI o ID interno...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                ),
                onChanged: _aplicarFiltro,
                ),
            ),

            const SizedBox(height: 4),

            // === LISTA ===
            Expanded(
                child: _tis.isEmpty
                    ? const Center(
                        child: Text('No se encontraron TIs con ese criterio.'),
                    )
                    : ListView.builder(
                        itemCount: _tis.length,
                        itemBuilder: (context, index) {
                        final ti = _tis[index];

                        return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                            title: Text(
                                ti.numTi,
                                style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                ),
                            ),
                            subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text(_formatearFecha(ti.fecha)),
                                const SizedBox(height: 4),
                                Text(
                                    'Origen: ${ti.almacenOrigen}  →  Destino: ${ti.almacenDestino}',
                                ),
                                ],
                            ),
                            trailing: Chip(
                                label: Text(
                                ti.estatus.toUpperCase(),
                                style: const TextStyle(fontSize: 11),
                                ),
                            ),
                            onTap: () {
                                Navigator.pushNamed(
                                context,
                                RoutePaths.jobsDetalleTi,
                                arguments: ti,
                                );
                            },
                            ),
                        );
                        },
                    ),
            ),
            ],
        ),
        );
    }
}
