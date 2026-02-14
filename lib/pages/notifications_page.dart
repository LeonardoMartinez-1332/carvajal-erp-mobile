import 'package:flutter/material.dart';

import '../data/notification_repository.dart';
import '../models/notification_item.dart';

class NotificationsPage extends StatefulWidget {
    const NotificationsPage({super.key});

    @override
    State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
    final NotificationRepository _repo = NotificationRepository();

    bool _loading = true;
    String? _error;
    List<NotificationItem> _items = [];

    @override
    void initState() {
        super.initState();
        _cargarNotificaciones();
    }

    Future<void> _cargarNotificaciones() async {
        setState(() {
        _loading = true;
        _error = null;
        });

        try {
        final data = await _repo.obtenerNotificaciones();
        setState(() {
            _items = data;
            _loading = false;
        });
        } catch (e) {
        setState(() {
            _error = 'Error al cargar notificaciones';
            _loading = false;
        });
        }
    }

    Future<void> _marcarComoLeida(NotificationItem n) async {
        if (n.leida) return;

        try {
        await _repo.marcarComoLeida(n.id);
        setState(() {
            final idx = _items.indexWhere((x) => x.id == n.id);
            if (idx != -1) {
            _items[idx] = NotificationItem(
                id: n.id,
                userId: n.userId,
                titulo: n.titulo,
                mensaje: n.mensaje,
                tipo: n.tipo,
                leida: true,
                modelo: n.modelo,
                modeloId: n.modeloId,
                createdAt: n.createdAt,
                updatedAt: n.updatedAt,
            );
            }
        });
        } catch (e) {
        // si quieres, muestra SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo marcar como leída')),
        );
        }
    }

    IconData _iconoPorTipo(String tipo) {
        switch (tipo) {
        case 'aprobacion':
            return Icons.verified_rounded;
        case 'alerta':
            return Icons.warning_amber_rounded;
        case 'info':
        default:
            return Icons.notifications_none_rounded;
        }
    }

    Color _colorPorTipo(String tipo, BuildContext context) {
        switch (tipo) {
        case 'aprobacion':
            return Colors.green;
        case 'alerta':
            return Colors.orange;
        case 'info':
        default:
            return Theme.of(context).colorScheme.primary;
        }
    }

    String _formatearFecha(DateTime? dt) {
        if (dt == null) return '';
        final local = dt.toLocal();
        // formato simple: yyyy-MM-dd HH:mm
        final s = local.toString(); // 2025-12-05 22:30:15.000
        return s.split('.').first; // quitamos milisegundos
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            title: const Text('Notificaciones'),
        ),
        body: _buildBody(),
        );
    }

    Widget _buildBody() {
        if (_loading) {
        return const Center(child: CircularProgressIndicator());
        }

        if (_error != null) {
        return Center(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Text(_error!),
                const SizedBox(height: 12),
                ElevatedButton(
                onPressed: _cargarNotificaciones,
                child: const Text('Reintentar'),
                ),
            ],
            ),
        );
        }

        if (_items.isEmpty) {
        return RefreshIndicator(
            onRefresh: _cargarNotificaciones,
            child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
                SizedBox(height: 80),
                Center(child: Text('No tienes notificaciones todavía')),
            ],
            ),
        );
        }

        return RefreshIndicator(
        onRefresh: _cargarNotificaciones,
        child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
            final n = _items[index];

            return InkWell(
                onTap: () async {
                await _marcarComoLeida(n);

                // TODO: aquí puedes navegar según n.modelo
                // if (n.modelo == 'bitacora') {
                //   Navigator.pushNamed(context, RoutePaths.adminBitacora, arguments: n.modeloId);
                // }

                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                decoration: BoxDecoration(
                    color: n.leida
                        ? Colors.grey.withOpacity(0.08)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                    BoxShadow(
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        color: Colors.black.withOpacity(0.06),
                    ),
                    ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Icono
                    Container(
                        decoration: BoxDecoration(
                        color: _colorPorTipo(n.tipo, context).withOpacity(0.12),
                        shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                        _iconoPorTipo(n.tipo),
                        color: _colorPorTipo(n.tipo, context),
                        size: 22,
                        ),
                    ),
                    const SizedBox(width: 12),
                    // Texto
                    Expanded(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Row(
                            children: [
                                Expanded(
                                child: Text(
                                    n.titulo,
                                    style: TextStyle(
                                    fontWeight:
                                        n.leida ? FontWeight.normal : FontWeight.bold,
                                    fontSize: 15,
                                    ),
                                ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                _formatearFecha(n.createdAt),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                ),
                                ),
                            ],
                            ),
                            if (n.mensaje != null && n.mensaje!.trim().isNotEmpty)
                            Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                n.mensaje!,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade800,
                                ),
                                ),
                            ),
                            if (!n.leida)
                            Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Row(
                                children: [
                                    Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                    ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                    'Nueva',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w600,
                                    ),
                                    ),
                                ],
                                ),
                            ),
                        ],
                        ),
                    ),
                    ],
                ),
                ),
            );
            },
        ),
        );
    }
}
