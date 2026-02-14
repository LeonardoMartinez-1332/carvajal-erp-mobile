import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../widgets/module_scaffold.dart';

// 🔹 Backend
import '../../core/app_config.dart';           // para AppConfig.apiBaseUrl
import '../../data/auth_repository.dart';
import '../../data/admin_unlock_repository.dart';
import '../../models/unlock_request.dart';

class AdminSolicitudesDesbloqueoPage extends StatefulWidget {
    const AdminSolicitudesDesbloqueoPage({super.key});

    @override
    State<AdminSolicitudesDesbloqueoPage> createState() =>
        _AdminSolicitudesDesbloqueoPageState();
}

class _AdminSolicitudesDesbloqueoPageState
    extends State<AdminSolicitudesDesbloqueoPage> {
    // 🔹 Repo real que pega al backend
    late final AdminUnlockRepository _repo = AdminUnlockRepository(
        baseUrl: AppConfig.apiBaseUrl,
        auth: AuthRepository(),
    );

    // Estado de la pantalla
    List<UnlockRequest> _items = [];
    bool _cargando = true;
    bool _procesando = false;
    String? _error;

    @override
    void initState() {
        super.initState();
        _cargarSolicitudes();
    }

    Future<void> _cargarSolicitudes() async {
        setState(() {
        _cargando = true;
        _error = null;
        });

        try {
        final data = await _repo.listarPendientes();
        if (!mounted) return;
        setState(() {
            _items = data;
            _cargando = false;
        });
        } catch (e) {
        if (!mounted) return;
        setState(() {
            _cargando = false;
            _error = 'Error al cargar solicitudes: $e';
        });
        }
    }

    Future<void> _cambiarEstado(UnlockRequest item, String nuevoEstado) async {
        setState(() => _procesando = true);

        try {
        if (nuevoEstado == 'aprobado') {
            await _repo.aprobar(item.id);
        } else {
            await _repo.rechazar(item.id);
        }

        if (!mounted) return;
        setState(() {
            final idx = _items.indexWhere((e) => e.id == item.id);
            if (idx != -1) {
            _items[idx] = _items[idx].copyWith(status: nuevoEstado);
            }
            _procesando = false;
        });

        final texto = nuevoEstado == 'aprobado'
            ? 'Solicitud aprobada y cuenta desbloqueada.'
            : 'Solicitud rechazada.';

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(texto)),
        );
        } catch (e) {
        if (!mounted) return;
        setState(() => _procesando = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al procesar la solicitud: $e')),
        );
        }
    }

    @override
    Widget build(BuildContext context) {
        return ModuleScaffold(
        title: 'Solicitudes de desbloqueo',
        appBarColor: AppColors.primary,
        body: Stack(
            children: [
            if (_cargando)
                const Center(child: CircularProgressIndicator())
            else if (_error != null)
                Center(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                        onPressed: _cargarSolicitudes,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        ),
                    ],
                    ),
                ),
                )
            else if (_items.isEmpty)
                const Center(
                child: Text(
                    'No hay solicitudes de desbloqueo pendientes.',
                    style: TextStyle(fontSize: 14),
                ),
                )
            else
                ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                    final item = _items[index];
                    return _SolicitudCard(
                    item: item,
                    onAprobar: () => _cambiarEstado(item, 'aprobado'),
                    onRechazar: () => _cambiarEstado(item, 'rechazado'),
                    );
                },
                ),

            if (_procesando)
                Container(
                color: Colors.black.withOpacity(0.06),
                child: const Center(child: CircularProgressIndicator()),
                ),
            ],
        ),
        );
    }
}

class _SolicitudCard extends StatelessWidget {
    const _SolicitudCard({
        required this.item,
        required this.onAprobar,
        required this.onRechazar,
    });

    final UnlockRequest item;
    final VoidCallback onAprobar;
    final VoidCallback onRechazar;

    Color _statusColor(String status) {
        switch (status) {
        case 'aprobado':
            return AppColors.success;
        case 'rechazado':
            return AppColors.danger;
        default:
            return AppColors.warning;
        }
    }

    String _statusText(String status) {
        switch (status) {
        case 'aprobado':
            return 'Aprobado';
        case 'rechazado':
            return 'Rechazado';
        default:
            return 'Pendiente';
        }
    }

    @override
    Widget build(BuildContext context) {
        final cs = Theme.of(context).colorScheme;
        final fecha = item.createdAt;

        return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                children: [
                    CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(.08),
                    foregroundColor: cs.primary,
                    child: const Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                            item.usuarioNombre ?? 'Usuario sin nombre',
                            style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                            item.email,
                            style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                            '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} '
                            '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                            ),
                        ),
                        ],
                    ),
                    ),
                    Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: _statusColor(item.status).withOpacity(.12),
                        borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                        _statusText(item.status),
                        style: TextStyle(
                        color: _statusColor(item.status),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        ),
                    ),
                    ),
                ],
                ),
                const SizedBox(height: 10),
                Text(
                item.motivo,
                style: const TextStyle(fontSize: 13.5),
                ),
                const SizedBox(height: 10),
                Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    TextButton.icon(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Rechazar'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                    ),
                    onPressed:
                        item.status == 'pendiente' ? onRechazar : null,
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Aprobar'),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                    ),
                    onPressed:
                        item.status == 'pendiente' ? onAprobar : null,
                    ),
                ],
                ),
            ],
            ),
        ),
        );
    }
}
