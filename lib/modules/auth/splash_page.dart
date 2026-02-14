import 'package:flutter/material.dart';
import '../../offline/session_store.dart';
import '../../data/auth_repository.dart';
import '../../models/user.dart';

class SplashPage extends StatefulWidget {
    const SplashPage({super.key});

    @override
    State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
    final _repo = AuthRepository();
    final _store = SessionStore();

    late final AnimationController _anim;
    late final Animation<double> _fade;
    late final Animation<double> _scale;
    late final Animation<Offset> _slide;

    @override
    void initState() {
        super.initState();

        // Animaciones del logo
        _anim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
        );
        _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
        _scale = Tween<double>(begin: .96, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack))
            .animate(_anim);
        _slide = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .animate(_anim);

        _anim.forward();
        _bootstrap(); // lógica de sesión
    }

    @override
    void dispose() {
        _anim.dispose();
        super.dispose();
    }

    Future<void> _bootstrap() async {
        try {
        // 1) Migración si antes hubo token en SharedPreferences
        await _store.migrateIfNeeded();

        // 2) Leer sesión local básica
        final token = await _store.token;
        final roleLocal = (await _store.role)?.toLowerCase();

        if (token == null || roleLocal == null) {
            _goLogin();
            return;
        }

        // 3) Caducidad por tiempo (ajusta a lo que quieras)
        const maxSessionAge = Duration(days: 7);
        final isOld = await _store.isSessionStale(maxSessionAge);
        if (isOld) {
            await _repo.logout(); // limpia local y remoto
            _goLogin();
            return;
        }

        // 4) Validar token contra /me y obtener UserModel real
        final UserModel? user = await _repo
            .validateAndGetUser()
            .timeout(const Duration(seconds: 12), onTimeout: () => null);

        if (!mounted) return;

        if (user == null) {
            // Token inválido / expirado
            _goLogin();
            return;
        }

        // (Opcional) refrescar “última actividad” en SessionStore
        await _store.markLoginNow();

        // 5) Navegar según rol que viene del backend
        final role = (user.role ?? roleLocal).toLowerCase();

        switch (role) {
            case 'supervisor':
            Navigator.of(context).pushReplacementNamed(
                '/home/supervisor',
                arguments: user,
            );
            break;
            case 'superusuario':
            case 'admin':
            Navigator.of(context).pushReplacementNamed(
                '/home/admin',
                arguments: user,
            );
            break;
            default:
            Navigator.of(context).pushReplacementNamed(
                '/home/user',
                arguments: user,
            );
            break;
        }
        } catch (_) {
        if (!mounted) return;
        // Fallback seguro
        _goLogin(message: 'No se pudo validar la sesión. Inicia de nuevo.');
        }
    }

    void _goLogin({String? message}) {
        if (!mounted) return;
        if (message != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        }
        // Tu ruta de login ("/")
        Navigator.of(context).pushReplacementNamed('/');
    }

    @override
    Widget build(BuildContext context) {
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
        backgroundColor: cs.surface,
        body: Stack(
            children: [
            // Gradiente suave de fondo (opcional)
            Positioned.fill(
                child: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [cs.surface, cs.surfaceVariant.withOpacity(.30)],
                    ),
                ),
                ),
            ),
            // Contenido centrado
            Center(
                child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                    position: _slide,
                    child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Image.asset(
                            'assets/Logo_Carvajal.png',
                            height: 110,
                            fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 18),
                        Text(
                            'ERP Carvajal',
                            style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                            ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(
                            height: 26,
                            width: 26,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                        ],
                    ),
                    ),
                ),
                ),
            ),
            ],
        ),
        );
    }
}
