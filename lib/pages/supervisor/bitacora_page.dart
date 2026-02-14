import 'dart:async'; // NUEVO
import 'package:flutter/material.dart';

import 'package:carvajal_erp/data/bitacora_repository.dart';
import 'package:carvajal_erp/data/auth_repository.dart';
import 'package:carvajal_erp/models/bitacora_entry.dart';

// Repo offline
import 'package:carvajal_erp/data/bitacora_offline_repository.dart';

// Escuchar cambios de conexión
import 'package:connectivity_plus/connectivity_plus.dart';

class BitacoraPage extends StatefulWidget {
    const BitacoraPage({super.key});

    @override
    State<BitacoraPage> createState() => _BitacoraPageState();
}

class _BitacoraPageState extends State<BitacoraPage>
    with SingleTickerProviderStateMixin {
    // 🔹 Repos
    late final BitacoraRepository _repo;
    late final BitacoraOfflineRepository _offlineRepo;
    final AuthRepository _auth = AuthRepository();

    final TextEditingController _searchCtrl = TextEditingController();

    late final AnimationController _anim;
    late final Animation<double> _fade;
    late final Animation<Offset> _slide;

    List<BitacoraEntry> _items = [];
    bool _loading = true;
    bool _initializing = true;
    bool _syncing = false;
    String? _error;

    // 👇 Para saber si ya tenemos repo listo
    bool _repoReady = false;

    // 👇 Estado de conexión actual
    bool _online = false;

    // 👇 Escucha de conectividad
    StreamSubscription<List<ConnectivityResult>>? _connSub;

    Color get _primary => const Color(0xFF0D47A1);

    @override
    void initState() {
        super.initState();

        _anim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
        );
        _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
        _slide = Tween(begin: const Offset(0, .04), end: Offset.zero).animate(
        CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
        );

        // 🔹 Empezamos a escuchar cambios de conexión
        _connSub = Connectivity()
            .onConnectivityChanged
            .listen((results) => _handleConnectivity(results));

        _initRepo();
    }

    @override
    void dispose() {
        _searchCtrl.dispose();
        _anim.dispose();
        _connSub?.cancel(); // cancelamos listener
        super.dispose();
    }

    Future<void> _initRepo() async {
        // Si no hay token, mandamos a login
        final token = await _auth.getToken();
        if (token == null) {
        if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
        }
        return;
        }

        _repo = BitacoraRepository();
        _offlineRepo = BitacoraOfflineRepository(_repo);

        _repoReady = true; // ya podemos usar sync automático

        // Revisamos cómo arrancamos en cuanto a conectividad
        final results = await Connectivity().checkConnectivity();
        final hasNet = results.any(
        (r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi,
        );

        setState(() {
        _initializing = false;
        _online = hasNet;
        });

        await _reload();

        // 🔹 Por si ya estamos conectados al abrir la pantalla, intentamos sync silencioso
        _handleConnectivity(results, silent: true);
    }

    /// 🔁 Recarga: intenta bajar de la API (si hay internet) y cachea en local.
    /// Luego siempre muestra desde BD local, con filtro de búsqueda.
    Future<void> _reload() async {
        setState(() {
        _loading = true;
        _error = null;
        });

        try {
        // Primero intentamos refrescar desde el servidor.
        // Si no hay internet o truena, ignoramos y usamos lo que haya en local.
        try {
            final remotos = await _repo.list();
            await _offlineRepo.reemplazarDesdeServidor(remotos);
        } catch (_) {
            // Nos quedamos con los datos locales.
        }

        final todos = await _offlineRepo.obtenerTodos();

        final q = _searchCtrl.text.trim().toLowerCase();
        final filtrados = q.isEmpty
            ? todos
            : todos.where((e) {
                bool match(String? s) =>
                    s != null && s.toLowerCase().contains(q);
                return match(e.numAsn) ||
                    match(e.placa) ||
                    match(e.origen) ||
                    match(e.destino) ||
                    match(e.estado);
                }).toList();

        setState(() {
            _items = filtrados;
            _loading = false;
        });
        _anim.forward(from: 0);
        } catch (e) {
        setState(() {
            _loading = false;
            _error = e.toString();
        });
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar la bitácora: $e')),
            );
        }
        }
    }

    String _fmtFechaHora(BitacoraEntry e) {
        final f = e.fecha;
        final h = e.horaLlegada;
        if (f.isEmpty && (h == null || h.isEmpty)) return '-';
        if (h == null || h.isEmpty) return f;
        return '$f $h';
    }

    Color _estadoColor(String estado) {
        switch (estado.toLowerCase()) {
        case 'programado':
            return const Color(0xFF1E88E5);
        case 'en descarga':
            return const Color(0xFFFFA726);
        case 'completado':
            return const Color(0xFF43A047);
        default:
            return Colors.blueGrey;
        }
    }

    IconData _syncIcon(String? status) {
        switch (status) {
        case 'pending':
            return Icons.schedule;
        case 'error':
            return Icons.error;
        default:
            return Icons.check_circle;
        }
    }

    Color _syncColor(String? status) {
        switch (status) {
        case 'pending':
            return Colors.amber;
        case 'error':
            return Colors.red;
        default:
            return Colors.green;
        }
    }

    /// 🔹 Badge visual para el estado de sincronización
    Widget _buildSyncBadge(BitacoraEntry e) {
        final status = e.syncStatus;

        if (status == 'pending') {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber),
            ),
            child: const Text(
            'Pendiente de sync',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.amber,
            ),
            ),
        );
        }

        if (status == 'error') {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red),
            ),
            child: const Text(
            'Error de sync',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.red,
            ),
            ),
        );
        }

        // Si está sincronizado o viene del servidor, no mostramos badge extra
        return const SizedBox.shrink();
    }

    /// 🔹 Maneja cambios de conexión
    void _handleConnectivity(List<ConnectivityResult> results,
        {bool silent = false}) {
        final hasNet = results.any(
        (r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi,
        );

        // Actualizamos el indicador visual
        if (mounted) {
        setState(() {
            _online = hasNet;
        });
        }

        // Si no tenemos repo listo o ya estamos sincronizando, no hacemos nada más
        if (!_repoReady || _syncing) return;

        // Si no hay red, aquí paramos
        if (!hasNet) return;

        // Cuando recuperamos conexión -> intentamos sincronizar
        _syncOffline(silent: silent);
    }

    /// Sincroniza pendientes con el backend.
    /// - `silent = true` → sin SnackBar (para auto-sync)
    Future<void> _syncOffline({bool silent = false}) async {
        if (_syncing) return;

        setState(() => _syncing = true);
        try {
        await _offlineRepo.sincronizarPendientes();
        await _reload();
        if (!silent && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sincronización completada.')),
            );
        }
        } catch (e) {
        if (!silent && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al sincronizar: $e')),
            );
        }
        } finally {
        if (mounted) {
            setState(() => _syncing = false);
        }
        }
    }

    /// 🟩 CREAR NUEVO REGISTRO (OFFLINE: se guarda local con syncStatus=pending)
    Future<void> _openCreate() async {
        final origenCtrl = TextEditingController();
        final destinoCtrl = TextEditingController();
        final rampaCtrl = TextEditingController();
        final tarimasCtrl = TextEditingController();
        final idTurnoCtrl = TextEditingController();
        final idTranspCtrl = TextEditingController();

        DateTime fechaSel = DateTime.now();
        String? horaLlegadaStr;
        String? horaSalidaStr;

        TimeOfDay? _parseTime(String? raw) {
        if (raw == null || raw.isEmpty) return null;
        final parts = raw.split(':');
        if (parts.length < 2) return null;
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: h, minute: m);
        }

        String _formatTime(TimeOfDay t) {
        String two(int n) => n.toString().padLeft(2, '0');
        return '${two(t.hour)}:${two(t.minute)}';
        }

        String _formatDate(DateTime d) {
        String two(int n) => n.toString().padLeft(2, '0');
        return '${d.year}-${two(d.month)}-${two(d.day)}';
        }

        final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (ctx) {
            return Padding(
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: StatefulBuilder(
                builder: (ctx, setStateModal) {
                return SingleChildScrollView(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.blueGrey.shade200,
                            borderRadius: BorderRadius.circular(4),
                        ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                        'Nuevo registro',
                        style: Theme.of(ctx)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),

                        // Origen
                        TextField(
                        controller: origenCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Origen',
                            prefixIcon: Icon(Icons.place_outlined),
                        ),
                        ),
                        const SizedBox(height: 10),

                        // Destino
                        TextField(
                        controller: destinoCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Destino',
                            prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        ),
                        const SizedBox(height: 10),

                        // Rampa
                        TextField(
                        controller: rampaCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Rampa (opcional)',
                            prefixIcon: Icon(Icons.stairs_outlined),
                        ),
                        ),
                        const SizedBox(height: 16),

                        // Fecha
                        ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text('Fecha'),
                        subtitle: Text(_formatDate(fechaSel)),
                        trailing: FilledButton.tonal(
                            onPressed: () async {
                            // 🔒 Limitar fechas: desde hoy hasta +30 días
                            final now = DateTime.now();
                            final today =
                                DateTime(now.year, now.month, now.day); // sin hora

                            final initial = fechaSel.isBefore(today)
                                ? today
                                : fechaSel;

                            final picked = await showDatePicker(
                                context: ctx,
                                initialDate: initial,
                                firstDate:
                                    today, // no permite fechas anteriores a hoy
                                lastDate: today.add(
                                const Duration(days: 30),
                                ),
                            );

                            if (picked != null) {
                                setStateModal(() => fechaSel = picked);
                            }
                            },
                            child: const Text('Cambiar'),
                        ),
                        ),
                        const SizedBox(height: 8),

                        // Hora de llegada
                        ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.login),
                        title: const Text('Hora de llegada'),
                        subtitle: Text(horaLlegadaStr ?? '-'),
                        trailing: FilledButton.tonal(
                            onPressed: () async {
                            final initial =
                                _parseTime(horaLlegadaStr) ?? TimeOfDay.now();
                            final t = await showTimePicker(
                                context: ctx,
                                initialTime: initial,
                            );
                            if (t != null) {
                                setStateModal(() {
                                horaLlegadaStr = _formatTime(t);
                                });
                            }
                            },
                            child: const Text('Cambiar'),
                        ),
                        ),
                        const SizedBox(height: 8),

                        // Hora de salida
                        ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.logout),
                        title: const Text('Hora de salida (opcional)'),
                        subtitle: Text(horaSalidaStr ?? '-'),
                        trailing: FilledButton.tonal(
                            onPressed: () async {
                            final initial =
                                _parseTime(horaSalidaStr) ?? TimeOfDay.now();
                            final t = await showTimePicker(
                                context: ctx,
                                initialTime: initial,
                            );
                            if (t != null) {
                                setStateModal(() {
                                horaSalidaStr = _formatTime(t);
                                });
                            }
                            },
                            child: const Text('Cambiar'),
                        ),
                        ),
                        const SizedBox(height: 8),

                        // Estado (solo lectura: Programado)
                        InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Estado',
                            prefixIcon: Icon(Icons.flag_circle_outlined),
                            border: OutlineInputBorder(),
                        ),
                        child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Programado',
                                style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            ),
                        ),
                        ),
                        const SizedBox(height: 12),

                        // ID Turno
                        TextField(
                        controller: idTurnoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'ID Turno',
                            prefixIcon: Icon(Icons.access_time),
                        ),
                        ),
                        const SizedBox(height: 8),

                        // ID Transporte (camión)
                        TextField(
                        controller: idTranspCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'ID Transporte (camión)',
                            prefixIcon: Icon(Icons.local_shipping_outlined),
                        ),
                        ),
                        const SizedBox(height: 8),

                        // Tarimas
                        TextField(
                        controller: tarimasCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Cantidad de tarimas',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                        children: [
                            Expanded(
                            child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                            ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                            child: FilledButton(
                                onPressed: () {
                                // Validación simple en cliente
                                if (origenCtrl.text.trim().isEmpty ||
                                    destinoCtrl.text.trim().isEmpty ||
                                    idTurnoCtrl.text.trim().isEmpty ||
                                    idTranspCtrl.text.trim().isEmpty ||
                                    tarimasCtrl.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                        'Origen, destino, ID turno, ID transporte y tarimas son obligatorios.',
                                        ),
                                    ),
                                    );
                                    return;
                                }

                                // Validación de fecha: no permitir días pasados
                                final now = DateTime.now();
                                final today = DateTime(
                                    now.year, now.month, now.day); // sin hora
                                final fechaSoloDia = DateTime(
                                    fechaSel.year, fechaSel.month, fechaSel.day);

                                if (fechaSoloDia.isBefore(today)) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                        'La fecha no puede ser anterior al día de hoy.',
                                        ),
                                    ),
                                    );
                                    return;
                                }

                                Navigator.pop(ctx, true);
                                },
                                child: const Text('Guardar'),
                            ),
                            ),
                        ],
                        ),
                    ],
                    ),
                );
                },
            ),
            );
        },
        );

        // Si canceló el modal
        if (result != true) {
        origenCtrl.dispose();
        destinoCtrl.dispose();
        rampaCtrl.dispose();
        tarimasCtrl.dispose();
        idTurnoCtrl.dispose();
        idTranspCtrl.dispose();
        return;
        }

        // Guardar local en modo OFFLINE (pendiente de sincronizar)
        try {
        final nuevo = BitacoraEntry(
            id: 0, // id remoto aún no existe
            numAsn: '', // aún no hay TI/FI asignada
            npi: null,
            estatusAprobacion: null,
            placa: null,
            origen: origenCtrl.text.trim(),
            destino: destinoCtrl.text.trim(),
            rampa: rampaCtrl.text.trim().isEmpty ? null : rampaCtrl.text.trim(),
            estado: 'Programado',
            fecha: _formatDate(fechaSel),
            horaLlegada: horaLlegadaStr,
            horaSalida: horaSalidaStr,
            cantidadTarimas: int.parse(tarimasCtrl.text.trim()),
            idTurno: int.parse(idTurnoCtrl.text.trim()),
            idTransp: int.parse(idTranspCtrl.text.trim()),
            idSupervisor: null,
            turnoNombre: null,
            supervisorNombre: null,
            syncStatus: 'pending',
        );

        await _offlineRepo.agregarLocal(nuevo);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Row(
                children: const [
                Icon(Icons.offline_bolt, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                    child: Text(
                    'Registro guardado offline — pendiente de sincronizar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ),
                ],
            ),
            backgroundColor: Colors.deepPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
            ),
        );
        await _reload();

        // 👇 Si al guardar hay internet, lanzamos sync automático en segundo plano
        final conn = await Connectivity().checkConnectivity();
        final hasNet = conn.any(
            (r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi,
        );
        if (hasNet) {
            _syncOffline(silent: true); // no bloqueamos la UI
        }
        } catch (err) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar localmente: $err')),
        );
        } finally {
        origenCtrl.dispose();
        destinoCtrl.dispose();
        rampaCtrl.dispose();
        tarimasCtrl.dispose();
        idTurnoCtrl.dispose();
        idTranspCtrl.dispose();
        }
    }

    /// EDICIÓN REAL: cambia estado, rampa y hora de salida
    /// Solo permitimos editar registros que ya estén sincronizados.
    Future<void> _openEdit(BitacoraEntry e) async {
        if (e.syncStatus == 'pending' || e.syncStatus == 'error') {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                'Este registro aún no se ha sincronizado con el servidor. '
                'Sincroniza primero para poder editarlo.',
                ),
            ),
            );
        }
        return;
        }

        final rampaCtrl = TextEditingController(text: e.rampa ?? '');
        String estado = e.estado;
        if (estado.toLowerCase() == 'programado') {
        estado = 'En descarga';
        }

        String? horaSalidaStr = e.horaSalida;

        TimeOfDay? _parseTime(String? raw) {
        if (raw == null || raw.isEmpty) return null;
        final parts = raw.split(':');
        if (parts.length < 2) return null;
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: h, minute: m);
        }

        String _formatTime(TimeOfDay t) {
        String two(int n) => n.toString().padLeft(2, '0');
        return '${two(t.hour)}:${two(t.minute)}';
        }

        final result = await showModalBottomSheet<Map<String, String?>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (ctx) {
            return Padding(
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: StatefulBuilder(
                builder: (ctx, setStateModal) {
                return SingleChildScrollView(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.blueGrey.shade200,
                            borderRadius: BorderRadius.circular(4),
                        ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                        'Recibir camión',
                        style: Theme.of(ctx)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),

                        // Rampa
                        TextField(
                        controller: rampaCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Rampa',
                            prefixIcon: Icon(Icons.stairs_outlined),
                        ),
                        ),
                        const SizedBox(height: 10),

                        // Estado
                        DropdownButtonFormField<String>(
                        value: estado,
                        items: const [
                            DropdownMenuItem(
                                value: 'En descarga', child: Text('En descarga')),
                            DropdownMenuItem(
                                value: 'Completado', child: Text('Completado')),
                        ],
                        decoration: const InputDecoration(
                            labelText: 'Estado',
                            prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        onChanged: (v) {
                            if (v == null) return;
                            setStateModal(() => estado = v);
                        },
                        ),
                        const SizedBox(height: 10),

                        // Hora de salida
                        ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.logout),
                        title: const Text('Hora de salida'),
                        subtitle: Text(horaSalidaStr ?? '-'),
                        trailing: FilledButton.tonal(
                            onPressed: () async {
                            final initial =
                                _parseTime(horaSalidaStr) ?? TimeOfDay.now();
                            final t = await showTimePicker(
                                context: ctx,
                                initialTime: initial,
                            );
                            if (t != null) {
                                setStateModal(() {
                                horaSalidaStr = _formatTime(t);
                                });
                            }
                            },
                            child: const Text('Cambiar'),
                        ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                        children: [
                            Expanded(
                            child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                            ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                            child: FilledButton(
                                onPressed: () {
                                Navigator.pop<Map<String, String?>>(
                                    ctx,
                                    {
                                    'estado': estado,
                                    'rampa': rampaCtrl.text.trim().isEmpty
                                        ? null
                                        : rampaCtrl.text.trim(),
                                    'hora_salida': horaSalidaStr,
                                    },
                                );
                                },
                                child: const Text('Guardar'),
                            ),
                            ),
                        ],
                        ),
                    ],
                    ),
                );
                },
            ),
            );
        },
        );

        rampaCtrl.dispose();

        // Si canceló, no hacemos nada
        if (result == null) return;

        try {
        await _repo.update(
            e.id,
            estado: result['estado'],
            rampa: result['rampa'],
            horaSalida: result['hora_salida'],
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro actualizado.')),
        );
        _reload();
        } catch (err) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar: $err')),
        );
        }
    }

    Future<void> _confirmDelete(BitacoraEntry e) async {
        final yes = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text('Eliminar registro'),
            content: Text(
            '¿Eliminar el registro ${e.numAsn} (${e.placa})? '
            'Esta acción no se puede deshacer.',
            ),
            actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
            ),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Eliminar'),
            ),
            ],
        ),
        );

        if (yes == true) {
        try {
            await _repo.delete(e.id);

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro eliminado.')),
            );
            _reload();
        } catch (err) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $err')),
            );
        }
        }
    }

    @override
    Widget build(BuildContext context) {
        if (_initializing) {
        return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
        );
        }

        return Scaffold(
        appBar: AppBar(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            title: const Text('Bitácora de camiones'),
            actions: [
            // Indicador de conexión
            Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                children: [
                    Icon(
                    _online ? Icons.wifi : Icons.wifi_off,
                    color: _online ? Colors.greenAccent : Colors.redAccent,
                    size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                    _online ? 'Online' : 'Offline',
                    style: const TextStyle(fontSize: 12),
                    ),
                ],
                ),
            ),
            IconButton(
                tooltip: 'Sincronizar pendientes',
                // Solo permitimos sync manual si hay red y no estamos ya syncando
                onPressed: (!_online || _syncing) ? null : () => _syncOffline(),
                icon:
                    _syncing ? const Icon(Icons.sync) : const Icon(Icons.cloud_sync),
            ),
            ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo'),
            onPressed: _openCreate,
        ),
        body: SafeArea(
            child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                colors: [
                    Color(0xFFEBF3FA),
                    Color(0xFFE3F2FD),
                    Color(0xFFE8EAF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                ),
            ),
            child: Column(
                children: [
                // Buscador
                Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                        hintText:
                            'Buscar por ASN, placa, origen, destino o estado…',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                        tooltip: 'Limpiar',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                            _searchCtrl.clear();
                            _reload();
                        },
                        ),
                    ),
                    onSubmitted: (_) => _reload(),
                    ),
                ),

                if (_error != null)
                    Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                        children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade400, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(
                            'Ocurrió un error al cargar la bitácora.\n$_error',
                            style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 12,
                            ),
                            ),
                        ),
                        ],
                    ),
                    ),

                Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : (_items.isEmpty)
                            ? const _EmptyState()
                            : FadeTransition(
                                opacity: _fade,
                                child: SlideTransition(
                                position: _slide,
                                child: ListView.separated(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                    itemCount: _items.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (ctx, i) {
                                    final e = _items[i];
                                    final estadoColor = _estadoColor(e.estado);
                                    final syncColor =
                                        _syncColor(e.syncStatus ?? 'synced');
                                    final syncIcon =
                                        _syncIcon(e.syncStatus ?? 'synced');

                                    return Material(
                                        color: Colors.white,
                                        elevation: 2,
                                        borderRadius: BorderRadius.circular(16),
                                        child: ListTile(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                        ),
                                        leading: CircleAvatar(
                                            backgroundColor:
                                                estadoColor.withOpacity(.12),
                                            child: Icon(
                                            Icons.local_shipping,
                                            color: estadoColor,
                                            ),
                                        ),
                                        title: Text(
                                            e.numAsn.isNotEmpty
                                                ? e.numAsn
                                                : (e.placa ?? 'Sin ASN'),
                                            style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            ),
                                        ),
                                        subtitle: Text(
                                            [
                                            if (e.placa != null)
                                                'Placa: ${e.placa}',
                                            if (e.origen.isNotEmpty)
                                                'Origen: ${e.origen}',
                                            if (e.destino.isNotEmpty)
                                                'Destino: ${e.destino}',
                                            _fmtFechaHora(e),
                                            if (e.turnoNombre != null)
                                                'Turno: ${e.turnoNombre}',
                                            if (e.supervisorNombre != null)
                                                'Supervisor: ${e.supervisorNombre}',
                                            ].join(' • '),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: Wrap(
                                            spacing: 4,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                            if (e.syncStatus == 'pending' ||
                                                e.syncStatus == 'error')
                                                _buildSyncBadge(e),

                                            // Icono de sync offline
                                            Icon(
                                                syncIcon,
                                                color: syncColor,
                                                size: 18,
                                            ),

                                            // Chip de estado
                                            Chip(
                                                label: Text(e.estado),
                                                backgroundColor:
                                                    estadoColor.withOpacity(.12),
                                                side:
                                                    BorderSide(color: estadoColor),
                                                labelStyle: TextStyle(
                                                color: estadoColor,
                                                fontWeight: FontWeight.w600,
                                                ),
                                            ),

                                            // Menú: Ver / Recibir camión
                                            PopupMenuButton<String>(
                                                onSelected: (v) {
                                                if (v == 'ver') {
                                                    _showDetalle(e);
                                                } else if (v == 'recibir') {
                                                    _openEdit(e);
                                                }
                                                },
                                                itemBuilder: (ctx) {
                                                final estadoLower =
                                                    e.estado.toLowerCase();
                                                final bool isCompletado =
                                                    estadoLower == 'completado';

                                                return [
                                                    const PopupMenuItem(
                                                    value: 'ver',
                                                    child: Text('Ver'),
                                                    ),
                                                    if (!isCompletado)
                                                    const PopupMenuItem(
                                                        value: 'recibir',
                                                        child:
                                                            Text('Recibir camión'),
                                                    ),
                                                ];
                                                },
                                            ),
                                            ],
                                        ),
                                        ),
                                    );
                                    },
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

    void _showDetalle(BitacoraEntry e, {bool editableHint = false}) {
        showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text('Detalle de registro'),
            content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _row('ASN (num_asn)', e.numAsn),
                _row('Placa', e.placa ?? '-'),
                _row('Origen', e.origen),
                _row('Destino', e.destino),
                _row('Rampa', e.rampa ?? '-'),
                _row('Estado', e.estado),
                _row('Fecha y llegada', _fmtFechaHora(e)),
                _row('Salida', e.horaSalida ?? '-'),
                _row('Tarimas', e.cantidadTarimas.toString()),
                _row('Turno', e.turnoNombre ?? '-'),
                _row('Supervisor', e.supervisorNombre ?? '-'),
                if (e.syncStatus != null) _row('Sync status', e.syncStatus!),
                if (editableHint)
                    const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                        'Edición desde app pendiente (hay que mapear catálogos de turno, transporte y supervisor).',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    ),
                ],
            ),
            ),
            actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar'),
            ),
            ],
        ),
        );
    }

    Widget _row(String k, String v) {
        return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
            children: [
            SizedBox(
                width: 140,
                child: Text(
                k,
                style: const TextStyle(fontWeight: FontWeight.w600),
                ),
            ),
            Expanded(child: Text(v)),
            ],
        ),
        );
    }
    }

    class _EmptyState extends StatelessWidget {
    const _EmptyState();

    @override
    Widget build(BuildContext context) {
        return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.inbox_outlined,
                size: 48, color: Colors.blueGrey.shade300),
            const SizedBox(height: 8),
            const Text('Sin registros locales'),
            const SizedBox(height: 4),
            const Text(
            'No hay registros en la bitácora local.\nSincroniza o crea uno nuevo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
        ]),
        );
    }
}
