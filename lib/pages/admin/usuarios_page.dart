import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../widgets/ui_bits.dart';
import '../../data/admin_usuarios_repository.dart';
import '../../models/admin_user.dart';

class AdminUsuariosPage extends StatefulWidget {
    const AdminUsuariosPage({super.key});

    @override
    State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
    final _repo = AdminUsuariosRepository();

    bool _loading = true;
    String? _error;
    List<AdminUser> _usuarios = [];
    String _search = '';

    @override
    void initState() {
        super.initState();
        _cargarUsuarios();
    }

    Future<void> _cargarUsuarios() async {
        setState(() {
        _loading = true;
        _error = null;
        });

        try {
        final data = await _repo.listar();
        setState(() {
            _usuarios = data;
            _loading = false;
        });
        } catch (e) {
        setState(() {
            _error = e.toString();
            _loading = false;
        });
        }
    }

    List<AdminUser> get _filtrados {
        if (_search.trim().isEmpty) return _usuarios;
        final q = _search.toLowerCase();
        return _usuarios.where((u) {
        return u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.role.toLowerCase().contains(q);
        }).toList();
    }

    Future<void> _confirmToggleActivo(AdminUser u) async {
        final nuevoEstado = !u.activo;

        final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
            title: Text(nuevoEstado ? 'Activar usuario' : 'Desactivar usuario'),
            content: Text(
            '¿Seguro que deseas ${nuevoEstado ? 'activar' : 'desactivar'} '
            'la cuenta de "${u.name}"?',
            ),
            actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
            ),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
            ),
            ],
        ),
        );

        if (ok != true) return;

        try {
        await _repo.cambiarEstado(u.id, nuevoEstado);
        await _cargarUsuarios();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(
                'Usuario ${nuevoEstado ? 'activado' : 'desactivado'} correctamente.',
            ),
            ),
        );
        } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
        );
        }
    }

    Future<void> _confirmEliminar(AdminUser u) async {
        final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
            title: const Text('Eliminar usuario'),
            content: Text(
                'Esta acción no se puede deshacer.\n\n'
                '¿Eliminar definitivamente a "${u.name}"?',
            ),
            actions: [
                TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
                ),
                FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.red[700],
                ),
                child: const Text('Eliminar'),
                ),
            ],
            ),
        );

        if (ok != true) return;

        try {
            await _repo.eliminar(u.id);
            await _cargarUsuarios();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario "${u.name}" eliminado correctamente.')),
            );
        } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                e.toString().replaceFirst('Exception: ', ''), 
            ),
            );
        }
    }


    String _fechaCorta(DateTime? d) {
        if (d == null) return '-';
        final dia = d.day.toString().padLeft(2, '0');
        final mes = d.month.toString().padLeft(2, '0');
        final anio = d.year.toString();
        return '$dia/$mes/$anio';
    }

    @override
    Widget build(BuildContext context) {
        const barColor = Color(0xFF37474F);

        return Scaffold(
        appBar: AppBar(
            backgroundColor: barColor,
            foregroundColor: Colors.white,
            title: const Text('Usuarios y roles'),
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
            final created = await Navigator.pushNamed(
            context,
            RoutePaths.adminNuevoUsuario,
            );

            if (!mounted) return;
            if (created == true) {
            _cargarUsuarios();
            }
            },
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Nuevo usuario'),
        ),
        body: GradientBackground(
            child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
                // Fila superior: resumen + buscador
                SectionCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(
                        'Gestión de usuarios',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey[900],
                            ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                        'Administra cuentas, roles y estado de acceso al ERP.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blueGrey[600],
                            ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                        decoration: InputDecoration(
                        hintText: 'Buscar por nombre, correo o rol...',
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                        ),
                        ),
                        onChanged: (v) => setState(() => _search = v),
                    ),
                    ],
                ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                padding: const EdgeInsets.all(0),
                child: _buildListado(context),
                ),
            ],
            ),
        ),
        );
    }

    Widget _buildListado(BuildContext context) {
        if (_loading) {
        return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
            child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            ),
        );
        }

        if (_error != null) {
        return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
            'Error al cargar usuarios:\n$_error',
            style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
            ),
            ),
        );
        }

        final data = _filtrados;
        if (data.isEmpty) {
        return const Padding(
            padding: EdgeInsets.all(20),
            child:
                Text('No hay usuarios registrados o no coinciden con la búsqueda.'),
        );
        }

        return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
            final u = data[index];
            return ListTile(
            leading: CircleAvatar(
                backgroundColor: u.activo ? Colors.green[100] : Colors.grey[300],
                child: Icon(
                Icons.person,
                color: u.activo ? Colors.green[800] : Colors.grey[700],
                ),
            ),
            title: Row(
                children: [
                Expanded(
                    child: Text(
                    u.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                ),
                const SizedBox(width: 8),
                Chip(
                    label: Text(
                    u.role.isEmpty ? 'Sin rol' : u.role,
                    style: const TextStyle(fontSize: 11),
                    ),
                ),
                ],
            ),
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(u.email),
                const SizedBox(height: 2),
                Text(
                    'Creado: ${_fechaCorta(u.createdAt)}'
                    '   •   Último acceso: ${_fechaCorta(u.lastLogin)}',
                    style: TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey[500],
                    ),
                ),
                ],
            ),
            isThreeLine: true,
            trailing: Wrap(
                spacing: 4,
                children: [
                // ✏️ EDITAR
                IconButton(
                    tooltip: 'Editar',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () async {
                    final updated = await Navigator.pushNamed(
                    context,
                    RoutePaths.adminNuevoUsuario,
                    arguments: u,
                    );

                    if (!mounted) return;
                    if (updated == true) {
                    _cargarUsuarios();
                    }
                    },
                ),
                // 🔁 ACTIVAR / DESACTIVAR
                IconButton(
                    tooltip: u.activo ? 'Desactivar' : 'Activar',
                    icon: Icon(
                    u.activo
                        ? Icons.toggle_on_rounded
                        : Icons.toggle_off_rounded,
                    size: 34,
                    color: u.activo ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => _confirmToggleActivo(u),
                ),
                // 🗑 ELIMINAR
                IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    ),
                    onPressed: () => _confirmEliminar(u),
                ),
                ],
            ),
            );
        },
        );
    }
}
