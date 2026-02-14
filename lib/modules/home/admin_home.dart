import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../data/auth_repository.dart';
import '../../core/app_theme.dart'; // ← para usar AppColors
import '../../core/routes.dart'; // ← para usar RoutePaths
import '../../widgets/notification_bell.dart'; // ← para usar NotificationBell



// UI kit reutilizable
import '../../core/ui_kit.dart';
import '../../widgets/module_scaffold.dart';

class AdminHome extends StatefulWidget {
    const AdminHome({super.key});

    @override
    State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
    late final AnimationController _ctrl;
    late final Animation<double> _fade;
    late final Animation<Offset> _slide;
    final _repo = AuthRepository();

    @override
    void initState() {
        super.initState();
        _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
        );
        _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
        _slide = Tween(begin: const Offset(0, .06), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
        );
        Future.delayed(const Duration(milliseconds: 150), () => _ctrl.forward());
    }

    @override
    void dispose() {
        _ctrl.dispose();
        super.dispose();
    }

    static int _cols(double w) {
        if (w >= 1200) return 4;
        if (w >= 900) return 3;
        if (w >= 600) return 2;
        return 1;
    }

    @override
    Widget build(BuildContext context) {
        final user = ModalRoute.of(context)!.settings.arguments as UserModel?;

        const adminBar = Color(0xFF37474F); // gris fuerte para Admin
        const tileBlue = Color(0xFF1976D2);
        const tileGreen = Color(0xFF2E7D32);
        const tilePurple = Color(0xFF6A1B9A);
        const tileOrange = Color(0xFFF57C00);
        const tileGrey = Color(0xFF455A64);
        const tileRed = Color(0xFFD32F2F);
        const tileIndigo = Color(0xFF283593); // aprobaciones TI/FI
        const tileTeal = Color(0xFF00897B);   // desbloqueo de usuarios

        return ModuleScaffold(
        title: 'Panel — Superusuario',
        appBarColor: adminBar,
        // Botón moderno de salir + confirmación
        actions: [
            // 🔔 Campanita de notificaciones
            Padding(
                padding: const EdgeInsets.only(right: 8),
                child: NotificationBell(
                onTap: () async {
                    await Navigator.pushNamed(context, RoutePaths.notificaciones);
                    setState(() {}); // esto dispara didUpdateWidget en la campana
                },
                ),
            ),

            Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
                style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.08),
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Salir'),
                onPressed: () async {
                final salir = await showDialog<bool>(
                    context: context,
                    builder: (ctx) {
                    return AlertDialog(
                        title: const Text('Cerrar sesión'),
                        content: const Text(
                        '¿Seguro que deseas cerrar sesión del ERP?',
                        ),
                        actions: [
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancelar'),
                        ),
                        FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Cerrar sesión'),
                        ),
                        ],
                    );
                    },
                );

                if (salir == true) {
                    await _repo.logout();
                    if (!mounted) return;
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (r) => false);
                }
                },
            ),
            ),
        ],

        // FAB: crear usuario rápido
        fab: FloatingActionButton.extended(
            backgroundColor: adminBar,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Nuevo usuario'),
            // ajusta la ruta si usas otra
            onPressed: () =>
                Navigator.pushNamed(context, '/admin/usuarios/nuevo'),
        ),

        body: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
            position: _slide,
            child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                // Bienvenida
                SectionCard(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                    child: Column(
                    children: [
                        Text(
                        'Bienvenido, ${user?.name ?? 'Administrador'}',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey[900],
                                ),
                        textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                        'Acceso completo al sistema.',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.blueGrey[600],
                                ),
                        textAlign: TextAlign.center,
                        ),
                    ],
                    ),
                ),
                const SizedBox(height: 18),

                // KPIs
                Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                    KpiBadge(
                        icon: Icons.people_alt,
                        label: 'Usuarios',
                        value: '24',
                        color: AppColors.info,
                    ),
                    KpiBadge(
                        icon: Icons.inventory_2,
                        label: 'Productos',
                        value: '1,248',
                        color: AppColors.success,
                    ),
                    KpiBadge(
                        icon: Icons.receipt_long,
                        label: 'Logs (24h)',
                        value: '3,412',
                        color: AppColors.warning,
                    ),
                    KpiBadge(
                        icon: Icons.security,
                        label: 'Alertas',
                        value: '2',
                        color: AppColors.danger,
                    ),
                    ],
                ),

                const SizedBox(height: 22),

                // Grid de módulos
                LayoutBuilder(
                    builder: (_, c) {
                    final cols = _cols(c.maxWidth);
                    return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                        _AdminTile(
                            color: tileBlue,
                            icon: Icons.manage_accounts,
                            title: 'Usuarios y roles',
                            subtitle: 'Altas • Bajas • Permisos',
                            onTap: () =>
                                Navigator.pushNamed(context, '/admin/usuarios'),
                        ),
                        _AdminTile(
                            color: tilePurple,
                            icon: Icons.inventory_2_outlined,
                            title: 'Catálogo de productos',
                            subtitle: 'CRUD • Importación • Validaciones',
                            onTap: () =>
                                Navigator.pushNamed(context, '/admin/productos'),
                        ),

                        // Aprobación de solicitudes TI/FI / Bitácora
                        _AdminTile(
                            color: tileIndigo,
                            icon: Icons.playlist_add_check_circle_rounded,
                            title: 'Aprobación de solicitudes',
                            subtitle: 'Pedidos TI/FI • Bitácora',
                            onTap: () =>
                                Navigator.pushNamed(context, '/admin/solicitudes'),
                        ),

                        // 🔓 Nueva card: solicitudes de desbloqueo de usuarios
                        _AdminTile(
                        color: tileTeal, // o el color que ya estabas usando
                        icon: Icons.lock_open_rounded,
                        title: 'Desbloqueo de usuarios',
                        subtitle: 'Cuentas bloqueadas • Alertas',
                        onTap: () => Navigator.pushNamed(
                            context,
                            RoutePaths.adminSolicitudesDesbloqueo,
                        ),
                        ),


                        _AdminTile(
                            color: tileGreen,
                            icon: Icons.dashboard_customize,
                            title: 'Dashboards / KPIs',
                            subtitle: 'Visión ejecutiva • Tendencias',
                            onTap: () =>
                                Navigator.pushNamed(context, '/admin/dashboard'),
                        ),
                        _AdminTile(
                            color: tileOrange,
                            icon: Icons.receipt_long_outlined,
                            title: 'Auditoría y logs',
                            subtitle: 'Trazabilidad • Acciones por usuario',
                            onTap: () =>
                                Navigator.pushNamed(context, '/admin/logs'),
                        ),
                        _AdminTile(
                            color: tileGrey,
                            icon: Icons.settings_suggest,
                            title: 'Configuración',
                            subtitle: 'Parámetros • Integraciones • ERP',
                            onTap: () =>
                                Navigator.pushNamed(context, '/admin/settings'),
                        ),
                        _AdminTile(
                            color: tileRed,
                            icon: Icons.backup_table_outlined,
                            title: 'Respaldos & mantenimiento',
                            subtitle: 'Backups • Limpieza • Jobs',
                            onTap: () => Navigator.pushNamed(
                                context, '/admin/mantenimiento'),
                        ),
                        ],
                    );
                    },
                ),
                ],
            ),
            ),
        ),
        );
    }
}

class _AdminTile extends StatefulWidget {
    const _AdminTile({
        required this.icon,
        required this.title,
        required this.subtitle,
        required this.onTap,
        required this.color,
    });

    final IconData icon;
    final String title;
    final String subtitle;
    final VoidCallback onTap;
    final Color color;

    @override
    State<_AdminTile> createState() => _AdminTileState();
}

class _AdminTileState extends State<_AdminTile> {
    bool _hover = false;

    @override
    Widget build(BuildContext context) {
        final elev = _hover ? 12.0 : 4.0;
        final scale = _hover ? 1.02 : 1.0;

        return MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedScale(
            duration: const Duration(milliseconds: 130),
            scale: scale,
            child: Material(
            elevation: elev,
            color: Colors.white.withOpacity(.96),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
                borderRadius: BorderRadius.circular(20),
                splashColor: widget.color.withOpacity(.10),
                onTap: widget.onTap,
                child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Icon(widget.icon, size: 38, color: widget.color),
                    const SizedBox(height: 16),
                    Text(
                        widget.title,
                        style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                        ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                        widget.subtitle,
                        style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        ),
                    ),
                    const Spacer(),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                        Icons.arrow_forward_rounded,
                        color: widget.color.withOpacity(.85),
                        ),
                    ),
                    ],
                ),
                ),
            ),
            ),
        ),
        );
    }
}
