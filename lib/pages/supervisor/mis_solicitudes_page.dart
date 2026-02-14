import 'package:flutter/material.dart';
import '../../data/bitacora_repository.dart';
import '../../models/bitacora_entry.dart';

class MisSolicitudesPage extends StatefulWidget {
    const MisSolicitudesPage({super.key});

    @override
    State<MisSolicitudesPage> createState() => _MisSolicitudesPageState();
}

class _MisSolicitudesPageState extends State<MisSolicitudesPage> {
    final _repo = BitacoraRepository();
    late Future<List<BitacoraEntry>> _future;
    String _search = '';

    @override
    void initState() {
        super.initState();
        _future = _repo.fetchMisSolicitudes();
    }

    void _reload() {
        setState(() {
        _future = _repo.fetchMisSolicitudes(search: _search);
        });
    }

    Color _statusColor(String status) {
        switch (status.toLowerCase()) {
        case 'pendiente':
        case 'pendiente de aprobación':
            return Colors.orange;
        case 'aprobado':
            return Colors.green;
        case 'rechazado':
            return Colors.red;
        default:
            return Colors.grey;
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            title: const Text('Pedidos / Solicitudes'),
        ),
        body: Column(
            children: [
            // 🔍 Barra de búsqueda
            Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar por NPI, TI/FI, origen o destino…',
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    ),
                ),
                onChanged: (value) {
                    _search = value;
                    _reload();
                },
                ),
            ),
            Expanded(
                child: FutureBuilder<List<BitacoraEntry>>(
                future: _future,
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}'),
                    );
                    }
                    final items = snapshot.data ?? [];

                    if (items.isEmpty) {
                    return const Center(
                        child: Text('Aún no tienes solicitudes registradas.'),
                    );
                    }

                    return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                        final e = items[index];
                        final status = e.estatusAprobacion ?? 'Desconocido';
                        final statusColor = _statusColor(status);

                        // Texto para el avatar
                        final rawNpi = e.npi ?? 'NP';
                        final avatarText = rawNpi.length >= 2
                            ? rawNpi.substring(0, 2)
                            : rawNpi;

                        return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                            // 🔹 Avatar con NPI
                            leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.1),
                            child: Text(
                                avatarText,
                                style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                ),
                            ),
                            ),

                            // 🔹 Título: NPI o "(sin NPI)"
                            title: Text(
                            e.npi ?? '(sin NPI)',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            ),

                            // 🔹 Subtítulo: origen, destino, fecha, tarimas y TI generada
                            subtitle: Text(
                            [
                                '${e.origen} → ${e.destino}',
                                'Fecha: ${e.fecha}',
                                'Tarimas: ${e.cantidadTarimas}',
                                if (status.toLowerCase() == 'aprobado' &&
                                    e.numAsn.isNotEmpty)
                                'TI generada: ${e.numAsn}', // 👈 aquí ve el TI cuando ya está aprobado
                            ].join('   •   '),
                            ),

                            // 🔹 Chip de estado
                            trailing: Chip(
                            label: Text(status),
                            backgroundColor: statusColor.withOpacity(0.1),
                            labelStyle: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                            ),
                            ),
                        ),
                        );
                    },
                    );
                },
                ),
            ),
            ],
        ),
        );
    }
}
