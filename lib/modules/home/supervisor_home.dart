import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../data/auth_repository.dart';
import '../../pages/product_import_page.dart';
import '../../core/routes.dart';
import '../../pages/supervisor/mis_solicitudes_page.dart';
import '../../widgets/notification_bell.dart'; // ← para usar NotificationBell

class SupervisorHome extends StatefulWidget {
    const SupervisorHome({super.key});

    @override
    State<SupervisorHome> createState() => _SupervisorHomeState();
}

class _SupervisorHomeState extends State<SupervisorHome>
    with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<double> fadeAnim;
    late Animation<Offset> slideAnim;

    final AuthRepository _repo = AuthRepository();

    UserModel? _user;
    bool _loadingUser = true;

    @override
    void initState() {
        super.initState();

        _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
        );
        fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
        slideAnim = Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );

        Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _controller.forward();
        });

        _initUser(); // validar sesión y rol
    }

    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }

    /// Inicializa el usuario:
    /// - Valida token contra /me
    /// - Verifica que el rol sea "supervisor"
    Future<void> _initUser() async {
        try {
        final backendUser = await _repo
            .validateAndGetUser()
            .timeout(const Duration(seconds: 12), onTimeout: () => null);

        if (!mounted) return;

        if (backendUser == null) {
            _goLogin(message: 'Tu sesión ha caducado. Inicia de nuevo.');
            return;
        }

        final role = (backendUser.role ?? '').toLowerCase();
        if (role != 'supervisor') {
            _goLogin(
            message: 'No tienes permisos para acceder al panel de supervisor.',
            );
            return;
        }

        setState(() {
            _user = backendUser;
            _loadingUser = false;
        });
        } catch (_) {
        if (!mounted) return;
        _goLogin(message: 'No se pudo validar la sesión. Intenta de nuevo.');
        }
    }

    void _goLogin({String? message}) {
        if (!mounted) return;
        if (message != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        }
        Navigator.of(context)
            .pushNamedAndRemoveUntil(RoutePaths.login, (r) => false);
    }

    static int _cols(double w) {
        if (w >= 1200) return 4;
        if (w >= 900) return 3;
        if (w >= 600) return 2;
        return 1;
    }

    @override
    Widget build(BuildContext context) {
        // Mientras validamos sesión
        if (_loadingUser) {
        final cs = Theme.of(context).colorScheme;
        return Scaffold(
            backgroundColor: cs.surface,
            body: Center(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                const SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.6),
                ),
                const SizedBox(height: 12),
                Text(
                    'Validando sesión...',
                    style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                    ),
                ),
                ],
            ),
            ),
        );
        }

        final userName = _user?.name ?? 'Supervisor';

        Future<void> _openImport() async {
        final token = await _repo.getToken();
        if (token == null || token.isEmpty) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay token de sesión')),
            );
            return;
        }
        if (!mounted) return;
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductImportPage(token: token)),
        );
        }

        return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            automaticallyImplyLeading:
                false, // 👈 sin flecha; home limpio como en Jobs/Admin
            title: const Text('Panel — Supervisor'),
            elevation: 4,
            actions: [
                // 🔔 Campanita de notificaciones
            Padding(
            padding: const EdgeInsets.only(right: 8),
            child: NotificationBell(
            onTap: () async {
                await Navigator.pushNamed(context, RoutePaths.notificaciones);
                setState(() {}); // vuelve a cargar el resumen al regresar
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
        ),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            onPressed: _openImport,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Importar'),
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
            width: double.infinity,
            child: FadeTransition(
                opacity: fadeAnim,
                child: SlideTransition(
                position: slideAnim,
                child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    children: [
                    _WelcomeCard(
                        userName: userName,
                        subtitle:
                            'Acceso: Consulta de productos + Bitácora de camiones.',
                    ),
                    const SizedBox(height: 18),
                    _AnimatedSection(
                        delay: 200,
                        child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: const [
                            _KpiMini(
                            icon: Icons.inventory_2,
                            label: 'Productos',
                            value: '1,248',
                            color: Color(0xFF1E88E5),
                            ),
                            _KpiMini(
                            icon: Icons.local_shipping,
                            label: 'Camiones hoy',
                            value: '7',
                            color: Color(0xFF43A047),
                            ),
                            _KpiMini(
                            icon: Icons.warning_amber_rounded,
                            label: 'Diferencias',
                            value: '3',
                            color: Color(0xFFF4511E),
                            ),
                        ],
                        ),
                    ),
                    const SizedBox(height: 22),
                    _AnimatedSection(
                        delay: 400,
                        child: LayoutBuilder(
                        builder: (context, c) {
                            final cols = _cols(c.maxWidth);
                            return GridView.count(
                            crossAxisCount: cols,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: [
                                _PanelTile(
                                icon: Icons.search,
                                title: 'Consulta de productos',
                                subtitle: 'Búsqueda • Detalle • Ubicación',
                                color: const Color(0xFF1976D2),
                                onTap: () => Navigator.pushNamed(
                                    context,
                                    '/supervisor/consulta',
                                ),
                                ),
                                _PanelTile(
                                icon: Icons.local_shipping_outlined,
                                title: 'Bitácora de camiones',
                                subtitle: 'Ver • Crear • Editar • Eliminar',
                                color: const Color(0xFF2E7D32),
                                onTap: () => Navigator.pushNamed(
                                    context,
                                    '/supervisor/bitacora',
                                ),
                                ),
                                _PanelTile(
                                icon: Icons.playlist_add_check_rounded,
                                title: 'Pedidos / Solicitudes',
                                subtitle:
                                    'Pendientes • Aprobadas • Rechazadas',
                                color: const Color(0xFF6A1B9A),
                                onTap: () {
                                    Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const MisSolicitudesPage(),
                                    ),
                                    );
                                },
                                ),
                            ],
                            );
                        },
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

/* ------------ WIDGETS DE APOYO ------------- */


class _AnimatedSection extends StatefulWidget {
    const _AnimatedSection({required this.child, required this.delay});
    final Widget child;
    final int delay;

    @override
    State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
    late AnimationController _ctrl;
    late Animation<double> fade;
    late Animation<Offset> slide;

    @override
    void initState() {
        super.initState();
        _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
        );
        fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
        slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
        );
        Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _ctrl.forward();
        });
    }

    @override
    void dispose() {
        _ctrl.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: widget.child),
        );
    }
}

class _WelcomeCard extends StatelessWidget {
    const _WelcomeCard({required this.userName, required this.subtitle});
    final String userName;
    final String subtitle;

    @override
    Widget build(BuildContext context) {
        return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
            BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 6),
            ),
            ],
        ),
        child: Column(
            children: [
            Text(
                'Bienvenido, $userName',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[900],
                    ),
                textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blueGrey[600],
                    ),
                textAlign: TextAlign.center,
            ),
            ],
        ),
        );
    }
}

class _PanelTile extends StatefulWidget {
    const _PanelTile({
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
    State<_PanelTile> createState() => _PanelTileState();
}

class _PanelTileState extends State<_PanelTile> {
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
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
                borderRadius: BorderRadius.circular(20),
                splashColor: widget.color.withOpacity(0.1),
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
                        color: widget.color.withOpacity(0.8),
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

class _KpiMini extends StatelessWidget {
    const _KpiMini({
        required this.icon,
        required this.label,
        required this.value,
        required this.color,
    });

    final IconData icon;
    final String label;
    final String value;
    final Color color;

    @override
    Widget build(BuildContext context) {
        return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 8),
            ],
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                    value,
                    style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: color,
                    ),
                ),
                const Text(''),
                Text(
                    label,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                ],
            ),
            ],
        ),
        );
    }
}
