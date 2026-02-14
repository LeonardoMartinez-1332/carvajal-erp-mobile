import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../data/auth_repository.dart';

// UI kit reutilizable
import '../../widgets/module_scaffold.dart';
import '../../widgets/ui_bits.dart';

// Rutas centralizadas
import '../../core/routes.dart';

class UserHome extends StatefulWidget {
    const UserHome({super.key});

    @override
    State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome>
    with SingleTickerProviderStateMixin {
    final _repo = AuthRepository();

    late final AnimationController _ctrl;
    late final Animation<double> _fade;
    late final Animation<Offset> _slide;

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
        if (w >= 1200) return 3;
        if (w >= 900) return 2;
        return 1;
    }

    @override
    Widget build(BuildContext context) {
        final user = ModalRoute.of(context)?.settings.arguments as UserModel?;
        const barColor = Color(0xFF1E88E5); // azul para usuario

        return ModuleScaffold(
        title: 'Panel — Usuario',
        appBarColor: barColor,
        actions: [
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    Navigator.of(context).pushNamedAndRemoveUntil(
                    RoutePaths.login,
                    (r) => false,
                    );
                }
                },
            ),
            ),
        ],
        fab: FloatingActionButton.extended(
            backgroundColor: barColor,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.report_problem_outlined),
            label: const Text('Reportar incidencia'),
            onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Módulo de reportes: próximamente')),
            );
            },
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 22),
                    child: Column(
                    children: [
                        Text(
                        'Bienvenido, ${user?.name ?? 'Usuario'}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey[900],
                            ),
                        textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                        'Consulta de productos y herramientas básicas.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: Colors.blueGrey[600],
                            ),
                        textAlign: TextAlign.center,
                        ),
                    ],
                    ),
                ),
                const SizedBox(height: 18),

                // KPIs mini (mock)
                Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                    KpiBadge(
                        icon: Icons.inventory_2,
                        label: 'Productos',
                        value: '1,248',
                        color: const Color(0xFF1E88E5),
                    ),
                    KpiBadge(
                        icon: Icons.star_rate_rounded,
                        label: 'Favoritos',
                        value: '8',
                        color: const Color(0xFF6A1B9A),
                    ),
                    KpiBadge(
                        icon: Icons.history,
                        label: 'Consultas',
                        value: '32',
                        color: const Color(0xFF43A047),
                    ),
                    ],
                ),

                const SizedBox(height: 22),

                // Accesos
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
                        _UserTile(
                            color: const Color(0xFF1976D2),
                            icon: Icons.search,
                            title: 'Consulta de productos',
                            subtitle: 'Búsqueda • Detalle • Ubicación',
                            onTap: () => Navigator.pushNamed(
                            context,
                            RoutePaths.supConsulta,
                            ),
                        ),
                        _UserTile(
                            color: const Color(0xFF00897B),
                            icon: Icons.person_outline,
                            title: 'Mi perfil',
                            subtitle: 'Datos • Contraseña',
                            onTap: () => Navigator.pushNamed(
                            context,
                            RoutePaths.userProfile,
                            ),
                        ),
                        _UserTile(
                            color: const Color(0xFFF57C00),
                            icon: Icons.help_outline,
                            title: 'Ayuda',
                            subtitle: 'Guías • Contacto',
                            onTap: () => Navigator.pushNamed(
                            context,
                            RoutePaths.userHelp,
                            ),
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

/// Tarjeta de acceso (mismo estilo que admin/supervisor)
class _UserTile extends StatefulWidget {
    const _UserTile({
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
    State<_UserTile> createState() => _UserTileState();
    }

    class _UserTileState extends State<_UserTile> {
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
