import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../data/auth_repository.dart';
import '../../core/routes.dart';

class JobsHome extends StatefulWidget {
    const JobsHome({super.key});

    @override
    State<JobsHome> createState() => _JobsHomeState();
}

class _JobsHomeState extends State<JobsHome>
    with SingleTickerProviderStateMixin {
    final _auth = AuthRepository();

    late final AnimationController _ctrl;
    late final Animation<double> _fade;
    late final Animation<Offset> _slide;

    @override
    void initState() {
        super.initState();
        _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
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
        final user = ModalRoute.of(context)!.settings.arguments as UserModel?;

        const barColor = Color(0xFF004D40); // verde oscuro Jobs

        return Scaffold(
        appBar: AppBar(
        backgroundColor: barColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // 👈 sin flecha en el panel Jobs
        title: const Text('Panel — Jobs'),
        actions: [
            Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
                style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: const BorderSide(color: Colors.white24),
                ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                'Salir',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                ),
                ),
                onPressed: () async {
                // 🔹 Diálogo de confirmación (igual que antes)
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
                    await _auth.logout();
                    if (!mounted) return;
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (r) => false);
                }
                },
            ),
            ),
        ],
        ),
        body: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
            position: _slide,
            child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                // Bienvenida
                Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                            'Bienvenido, ${user?.name ?? 'Analista Jobs'}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.teal[900],
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            'Aquí puedes generar TI directas desde inventario, sin flujo de aprobación.',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.blueGrey[600],
                                    ),
                        ),
                        ],
                    ),
                    ),
                ),
                const SizedBox(height: 22),

                // Grid de módulos Jobs
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
                        _JobsTile(
                            icon: Icons.playlist_add_rounded,
                            color: const Color(0xFF00796B),
                            title: 'Nueva TI directa',
                            subtitle: 'Seleccionar material de almacén',
                            onTap: () {
                            Navigator.pushNamed(
                                context, RoutePaths.jobsNuevaTi);
                            },
                        ),
                        _JobsTile(
                            icon: Icons.history_rounded,
                            color: const Color(0xFF455A64),
                            title: 'Historial de TI',
                            subtitle: 'Consultas rápidas por NPI / TI',
                            onTap: () {
                            Navigator.pushNamed(
                                context, RoutePaths.jobsHistorialTi);
                            },
                        ),
                        _JobsTile(
                            icon: Icons.insights,
                            title: 'Reportes Jobs',
                            subtitle: 'Mini KPIs de transferencias',
                            color: Colors.purple,
                            onTap: () => Navigator.pushNamed(
                                context, RoutePaths.jobsReportes),
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

class _JobsTile extends StatefulWidget {
    const _JobsTile({
        required this.icon,
        required this.title,
        required this.subtitle,
        required this.color,
        required this.onTap,
    });

    final IconData icon;
    final String title;
    final String subtitle;
    final Color color;
    final VoidCallback onTap;

    @override
    State<_JobsTile> createState() => _JobsTileState();
}

class _JobsTileState extends State<_JobsTile> {
    bool _hover = false;

    @override
    Widget build(BuildContext context) {
        final elev = _hover ? 10.0 : 3.0;
        final scale = _hover ? 1.02 : 1.0;

        return MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: scale,
            child: Material(
            elevation: elev,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onTap,
                splashColor: widget.color.withOpacity(.12),
                child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Icon(widget.icon, size: 36, color: widget.color),
                    const SizedBox(height: 14),
                    Text(
                        widget.title,
                        style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                        ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                        widget.subtitle,
                        style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
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
