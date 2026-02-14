import 'package:flutter/material.dart';

import '../../data/admin_usuarios_repository.dart';
import '../../models/admin_user.dart';
import '../../widgets/ui_bits.dart'; // GradientBackground, SectionCard, etc.

class AdminUsuarioFormPage extends StatefulWidget {
    const AdminUsuarioFormPage({super.key, this.usuario});

    /// null = modo CREAR, no null = modo EDITAR
    final AdminUser? usuario;

    @override
    State<AdminUsuarioFormPage> createState() => _AdminUsuarioFormPageState();
}

class _AdminUsuarioFormPageState extends State<AdminUsuarioFormPage> {
    final _formKey = GlobalKey<FormState>();

    final _nombreCtrl = TextEditingController();
    final _correoCtrl = TextEditingController();
    final _passwordCtrl = TextEditingController();
    final _password2Ctrl = TextEditingController();

    String _rol = 'usuario';
    bool _activo = true;
    bool _saving = false;

    final _repo = AdminUsuariosRepository();

    bool get _esEdicion => widget.usuario != null;

    @override
        void initState() {
        super.initState();

        final u = widget.usuario;
        if (u != null) {
            _nombreCtrl.text = u.name;      // 👈 ANTES: u.nombre
            _correoCtrl.text = u.email;     // 👈 ANTES: u.correo
            _rol = u.role;
            _activo = u.activo;
        }
    }


    @override
    void dispose() {
        _nombreCtrl.dispose();
        _correoCtrl.dispose();
        _passwordCtrl.dispose();
        _password2Ctrl.dispose();
        super.dispose();
    }

    Future<void> _guardar() async {
        if (!_formKey.currentState!.validate()) return;

        setState(() => _saving = true);

        try {
        if (_esEdicion) {
            // EDITAR
            await _repo.actualizarUsuario(
            id: widget.usuario!.id,
            nombre: _nombreCtrl.text.trim(),
            correo: _correoCtrl.text.trim(),
            role: _rol,
            activo: _activo,
            // Si viene vacía, no cambiamos password
            password:
                _passwordCtrl.text.trim().isEmpty ? null : _passwordCtrl.text,
            );
        } else {
            // CREAR
            await _repo.crearUsuario(
            nombre: _nombreCtrl.text.trim(),
            correo: _correoCtrl.text.trim(),
            password: _passwordCtrl.text,
            rol: _rol,
            activo: _activo,
            );
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(_esEdicion
                ? 'Usuario actualizado correctamente'
                : 'Usuario creado correctamente'),
            ),
        );

        Navigator.of(context).pop(true); // avisamos que hubo cambios
        } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
        );
        setState(() => _saving = false);
        }
    }

    @override
    Widget build(BuildContext context) {
        final cs = Theme.of(context).colorScheme;
        final esEdicion = _esEdicion;

        return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFF37474F),
            foregroundColor: Colors.white,
            title: Text(esEdicion ? 'Editar usuario' : 'Nuevo usuario'),
        ),
        body: GradientBackground(
            child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                    SectionCard(
                    title: 'Datos del usuario',
                    subtitle: esEdicion
                        ? 'Actualiza la información de la cuenta.'
                        : 'Completa la información para crear la cuenta.',
                    child: Form(
                        key: _formKey,
                        child: Column(
                        children: [
                            TextFormField(
                            controller: _nombreCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Nombre',
                                prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                return 'Ingresa el nombre';
                                }
                                return null;
                            },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                            controller: _correoCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Correo',
                                prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                return 'Ingresa el correo';
                                }
                                if (!v.contains('@') || !v.contains('.')) {
                                return 'Correo no válido';
                                }
                                return null;
                            },
                            ),
                            const SizedBox(height: 12),
                            Row(
                            children: [
                                Expanded(
                                child: DropdownButtonFormField<String>(
                                    value: _rol,
                                    decoration: const InputDecoration(
                                    labelText: 'Rol',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                    ),
                                    items: const [
                                    DropdownMenuItem(
                                        value: 'usuario',
                                        child: Text('Usuario'),
                                    ),
                                    DropdownMenuItem(
                                        value: 'supervisor',
                                        child: Text('Supervisor'),
                                    ),
                                    DropdownMenuItem(
                                        value: 'superusuario',
                                        child: Text('Superusuario'),
                                    ),
                                    DropdownMenuItem(
                                        value: 'jobs',
                                        child: Text('Jobs'),
                                    ),
                                    ],
                                    onChanged: (v) {
                                    if (v != null) {
                                        setState(() => _rol = v);
                                    }
                                    },
                                ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    const Text('Activo'),
                                    Switch(
                                    value: _activo,
                                    onChanged: (v) =>
                                        setState(() => _activo = v),
                                    activeColor: cs.primary,
                                    ),
                                ],
                                ),
                            ],
                            ),
                            const SizedBox(height: 16),

                            // Password
                            TextFormField(
                            controller: _passwordCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            validator: (v) {
                                if (v == null || v.isEmpty) {
                                // Crear: obligatorio, Editar: opcional
                                if (!esEdicion) {
                                    return 'Ingresa una contraseña';
                                }
                                // edición y vacío -> no cambiar contraseña
                                return null;
                                }
                                if (v.length < 6) {
                                return 'Mínimo 6 caracteres';
                                }
                                return null;
                            },
                            ),
                            const SizedBox(height: 12),

                            // Repetir password
                            TextFormField(
                            controller: _password2Ctrl,
                            decoration: const InputDecoration(
                                labelText: 'Repetir contraseña',
                                prefixIcon: Icon(Icons.lock_reset),
                            ),
                            obscureText: true,
                            validator: (v) {
                                if (v == null || v.isEmpty) {
                                if (!esEdicion) {
                                    return 'Repite la contraseña';
                                }
                                // en edición, si la principal está vacía, se ignora
                                if (_passwordCtrl.text.isEmpty) {
                                    return null;
                                }
                                return 'Repite la contraseña';
                                }
                                if (v != _passwordCtrl.text) {
                                return 'Las contraseñas no coinciden';
                                }
                                return null;
                            },
                            ),
                        ],
                        ),
                    ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                        onPressed: _saving ? null : _guardar,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                        _saving
                            ? (esEdicion
                                ? 'Guardando cambios...'
                                : 'Guardando...')
                            : (esEdicion
                                ? 'Guardar cambios'
                                : 'Guardar usuario'),
                        ),
                    ),
                    ),
                ],
                ),
            ),
            ),
        ),
        );
    }
}
