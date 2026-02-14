import 'package:flutter/material.dart';

import '../../data/bitacora_repository.dart';
import '../../models/bitacora_entry.dart';

class AdminSolicitudesPage extends StatefulWidget {
    const AdminSolicitudesPage({super.key});

    @override
    State<AdminSolicitudesPage> createState() => _AdminSolicitudesPageState();
}

class _AdminSolicitudesPageState extends State<AdminSolicitudesPage> {
    final _repo = BitacoraRepository();
    late Future<List<BitacoraEntry>> _future;
    String _search = '';

    @override
    void initState() {
        super.initState();
        _future = _repo.fetchPendientes(); // 👈 usa el endpoint /bitacora-camiones/pendientes
    }

    void _reload() {
        setState(() {
        _future = _repo.fetchPendientes(search: _search);
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

    Future<void> _confirmAprobar(BitacoraEntry e) async {
        final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text('Aprobar solicitud'),
            content: Text(
            '¿Aprobar el NPI ${e.npi ?? '(sin NPI)'}\n'
            'de ${e.origen} → ${e.destino}?',
            ),
            actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
            ),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Aprobar'),
            ),
            ],
        ),
        );

        if (ok != true) return;

        try {
        await _repo.aprobar(e.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Solicitud aprobada. Se generó TI/FI en la bitácora.'),
            ),
        );
        _reload();
        } catch (err) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al aprobar: $err')),
        );
        }
    }

    Future<void> _confirmRechazar(BitacoraEntry e) async {
        final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text('Rechazar solicitud'),
            content: Text(
            '¿Rechazar el NPI ${e.npi ?? '(sin NPI)'}\n'
            'de ${e.origen} → ${e.destino}?',
            ),
            actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
            ),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                ),
                child: const Text('Rechazar'),
            ),
            ],
        ),
        );

        if (ok != true) return;

        try {
        await _repo.rechazar(e.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Solicitud rechazada.'),
            ),
        );
        _reload();
        } catch (err) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al rechazar: $err')),
        );
        }
    }

    @override
    Widget build(BuildContext context) {
        const adminBar = Color(0xFF37474F);

        return Scaffold(
        appBar: AppBar(
            backgroundColor: adminBar,
            foregroundColor: Colors.white,
            title: const Text('Aprobación de solicitudes'),
        ),
        body: Column(
            children: [
            // 🔍 barra de búsqueda
            Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar por NPI, origen, destino…',
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
                        child: Text(
                        'No hay solicitudes pendientes por aprobar.',
                        textAlign: TextAlign.center,
                        ),
                    );
                    }

                    return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                        final e = items[index];
                        final status = e.estatusAprobacion ?? 'Pendiente';
                        final color = _statusColor(status);

                        final rawNpi = e.npi ?? 'NP';
                        final avatarText = rawNpi.length >= 2
                            ? rawNpi.substring(0, 2)
                            : rawNpi;

                        return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                        ),
                        child: ListTile(
                            leading: CircleAvatar(
                            backgroundColor: color.withOpacity(.08),
                            child: Text(
                                avatarText,
                                style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                ),
                            ),
                            ),
                            title: Text(
                            e.npi ?? '(sin NPI)',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                                [
                                '${e.origen} → ${e.destino}',
                                'Fecha: ${e.fecha}',
                                'Tarimas: ${e.cantidadTarimas}',
                                ].join('   •   '),
                            ),
                            ),
                            trailing: Wrap(
                            spacing: 4,
                            children: [
                                // Chip de estado
                                Chip(
                                label: Text(status),
                                backgroundColor: color.withOpacity(.08),
                                labelStyle: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                ),
                                ),
                                IconButton(
                                tooltip: 'Aprobar',
                                icon: const Icon(Icons.check_circle_outline),
                                color: Colors.green.shade700,
                                onPressed: () => _confirmAprobar(e),
                                ),
                                IconButton(
                                tooltip: 'Rechazar',
                                icon: const Icon(Icons.cancel_outlined),
                                color: Colors.red.shade700,
                                onPressed: () => _confirmRechazar(e),
                                ),
                            ],
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

