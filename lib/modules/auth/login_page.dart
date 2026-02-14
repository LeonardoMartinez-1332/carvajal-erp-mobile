import 'package:flutter/material.dart';

import '../../data/auth_repository.dart';
import '../../models/user.dart';
import '../../offline/email_store.dart';

// Fondo degradado y estilos
import '../../widgets/ui_bits.dart';
import '../../core/app_theme.dart';

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    final _emailCtrl = TextEditingController();
    final _passCtrl = TextEditingController();

    final _repo = AuthRepository();
    final _emailStore = EmailStore();

    bool _loading = false;
    String? _error;

    bool _obscure = true;
    bool _remember = true;

    late final AnimationController _anim;
    late final Animation<Offset> _slide;
    late final Animation<double> _fade;

    @override
    void initState() {
        super.initState();
        _bootstrapEmail();

        _anim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
        );
        _slide = Tween<Offset>(
        begin: const Offset(0, .06),
        end: Offset.zero,
        ).chain(
        CurveTween(curve: Curves.easeOutCubic),
        ).animate(_anim);
        _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);

        Future.delayed(const Duration(milliseconds: 120), _anim.forward);
    }

    Future<void> _bootstrapEmail() async {
        final data = await _emailStore.load();
        if (!mounted) return;
        setState(() {
        _remember = data.remember;
        if (data.email != null) _emailCtrl.text = data.email!;
        });
    }

    @override
    void dispose() {
        _anim.dispose();
        _emailCtrl.dispose();
        _passCtrl.dispose();
        super.dispose();
    }

    void _goToHome(UserModel user) {
        final role = user.role.toLowerCase();

        if (role == 'supervisor') {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/home/supervisor',
            (route) => false,
            arguments: user,
        );
        } else if (role == 'superusuario' || role == 'admin') {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/home/admin',
            (route) => false,
            arguments: user,
        );
        } else if (role == 'jobs') {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/home/jobs',
            (route) => false,
            arguments: user,
        );
        } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/home/user',
            (route) => false,
            arguments: user,
        );
        }
    }

    /// ================== LOGIN ==================
    Future<void> _onSubmit() async {
        if (!_formKey.currentState!.validate()) return;
        setState(() {
        _loading = true;
        _error = null;
        });

        try {
        final user = await _repo.login(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
        );

        await _emailStore.save(
            email: _emailCtrl.text.trim(),
            remember: _remember,
        );

        if (!mounted) return;
        _goToHome(user);
        } on ApiException catch (e) {
        // Interpretamos tanto el "code" como el statusCode y el mensaje
        String msg;
        final lowerMessage = e.message.toLowerCase();

        // 🔹 Fallback pro: si no viene code pero es 403 y habla de "bloqueado",
        // lo tratamos como account_locked.
        final derivedCode = (e.code ?? '').toLowerCase().isNotEmpty
            ? (e.code ?? '').toLowerCase()
            : ((e.statusCode == 403 &&
                    (lowerMessage.contains('bloquead') ||
                        lowerMessage.contains('blocked')))
                ? 'account_locked'
                : null);

        if (derivedCode == 'account_locked') {
            msg =
                'Tu cuenta ha sido bloqueada por varios intentos fallidos.\nPuedes solicitar el desbloqueo al administrador.';
            _mostrarDialogoCuentaBloqueada(
            e.message.isNotEmpty ? e.message : null,
            );
        } else if (derivedCode == 'invalid_credentials' ||
            e.statusCode == 401) {
            msg = 'Correo o contraseña incorrectos.';
        } else if (derivedCode == 'user_inactive' ||
            (e.statusCode == 403 && lowerMessage.contains('inactivo'))) {
            msg =
                'Tu usuario se encuentra inactivo. Contacta a tu administrador para revisar tu acceso.';
        } else {
            msg = e.message.isNotEmpty
                ? e.message
                : 'Error de autenticación (${e.statusCode}).';
        }

        if (mounted) {
            setState(() => _error = msg);
        }
        } catch (e) {
        if (mounted) {
            setState(() {
            _error = 'Error inesperado: $e';
            });
        }
        } finally {
        if (mounted) setState(() => _loading = false);
        }
    }

    /// =========== DIALOGO CUENTA BLOQUEADA ===========
    void _mostrarDialogoCuentaBloqueada(String? backendMessage) {
        final email = _emailCtrl.text.trim();

        showDialog(
        context: context,
        builder: (context) {
            final cs = Theme.of(context).colorScheme;
            return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            title: Row(
                children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                    color: cs.errorContainer,
                    shape: BoxShape.circle,
                    ),
                    child: Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: cs.onErrorContainer,
                    ),
                ),
                const SizedBox(width: 10),
                const Text('Cuenta bloqueada'),
                ],
            ),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                    backendMessage ??
                        'Detectamos varios intentos fallidos en tu cuenta.',
                ),
                const SizedBox(height: 8),
                const Text(
                    'Por seguridad, tu usuario fue bloqueado.\n'
                    'Puedes enviar una solicitud de desbloqueo para que un administrador revise tu caso.',
                    style: TextStyle(fontSize: 13),
                ),
                if (email.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                    'Usuario:',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                    ),
                    ),
                    Text(
                    email,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                    ),
                    ),
                ],
                ],
            ),
            actions: [
                TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
                ),
                FilledButton.icon(
                icon: const Icon(Icons.lock_open_outlined, size: 18),
                onPressed: () async {
                    Navigator.pop(context);
                    await _solicitarDesbloqueo();
                },
                label: const Text('Solicitar desbloqueo'),
                ),
            ],
            );
        },
        );
    }

    /// =========== SOLICITUD DE DESBLOQUEO ===========
    Future<void> _solicitarDesbloqueo() async {
        final email = _emailCtrl.text.trim();

        if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Ingresa el correo antes de solicitar desbloqueo.'),
            ),
        );
        return;
        }

        try {
        await _repo.solicitarDesbloqueo(
            email: email,
            motivo: 'Solicitud de desbloqueo desde pantalla de login.',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text(
                'Solicitud de desbloqueo enviada. '
                'Un administrador revisará tu caso.',
            ),
            ),
        );
        } on ApiException catch (e) {
        if (!mounted) return;

        String msg;
        final code = (e.code ?? '').toLowerCase();

        if (code == 'unlock_request_exists' || e.statusCode == 409) {
            msg =
                'Ya existe una solicitud de desbloqueo pendiente para este usuario.\n'
                'En cuanto un administrador la revise, podrás volver a intentar iniciar sesión.';
        } else if (code == 'user_not_blocked' || e.statusCode == 422) {
            msg =
                'Este usuario ya no se encuentra bloqueado.\n'
                'Intenta iniciar sesión nuevamente.';
        } else if (code == 'user_not_found' || e.statusCode == 404) {
            msg = 'No existe un usuario registrado con ese correo.';
        } else {
            msg = e.message.isNotEmpty
                ? e.message
                : 'No se pudo registrar la solicitud (${e.statusCode}).';
        }

        showDialog(
            context: context,
            builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
            ),
            title: const Text('Aviso'),
            content: Text(msg),
            actions: [
                TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
                ),
            ],
            ),
        );
        } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content:
                Text('No se pudo enviar la solicitud de desbloqueo: $e'),
            ),
        );
        }
    }

    /// ================== UI ==================
    @override
    Widget build(BuildContext context) {
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
        body: GradientBackground(
            child: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                    position: _slide,
                    child: Material(
                        color: Colors.white,
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(.08),
                        borderRadius: BorderRadius.circular(22),
                        child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 26, 30, 22),
                        child: Form(
                            key: _formKey,
                            child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                // Logo
                                Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _LogoHeader(),
                                ),

                                Text(
                                'ERP Carvajal Empaques',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                    ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                'Conectando soluciones. Impulsando éxitos.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: AppColors.textSecondary,
                                    ),
                                ),
                                const SizedBox(height: 16),
                                const Divider(height: 1),

                                const SizedBox(height: 14),
                                Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Icon(
                                    Icons.login_rounded,
                                    size: 18,
                                    color: cs.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                    'Inicio de Sesión',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                        ),
                                    ),
                                ],
                                ),
                                const SizedBox(height: 14),

                                // Email
                                TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                decoration: InputDecoration(
                                    labelText: 'Correo electrónico',
                                    prefixIcon: const Icon(
                                        Icons.alternate_email_rounded),
                                    border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    ),
                                    filled: true,
                                    fillColor:
                                        cs.surfaceVariant.withOpacity(0.12),
                                ),
                                validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                    return 'Ingresa tu correo';
                                    }
                                    if (!v.contains('@')) {
                                    return 'Correo inválido';
                                    }
                                    return null;
                                },
                                ),
                                const SizedBox(height: 12),

                                // Password
                                TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    prefixIcon: const Icon(
                                        Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(
                                    tooltip:
                                        _obscure ? 'Mostrar' : 'Ocultar',
                                    icon: Icon(
                                        _obscure
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscure = !_obscure),
                                    ),
                                    border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    ),
                                    filled: true,
                                    fillColor:
                                        cs.surfaceVariant.withOpacity(0.12),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Ingresa tu contraseña'
                                    : null,
                                ),

                                const SizedBox(height: 6),
                                Row(
                                children: [
                                    Checkbox(
                                    value: _remember,
                                    visualDensity:
                                        VisualDensity.compact,
                                    onChanged: (v) => setState(
                                        () => _remember = v ?? false),
                                    ),
                                    const Text('Recordarme'),
                                    const Spacer(),
                                    TextButton(
                                    onPressed: _loading
                                        ? null
                                        : _solicitarDesbloqueo,
                                    child: const Text(
                                        '¿Olvidaste tu contraseña?',
                                    ),
                                    ),
                                ],
                                ),

                                if (_error != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                    color: cs.errorContainer
                                        .withOpacity(.35),
                                    borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                        Icon(
                                        Icons.info_outline_rounded,
                                        size: 18,
                                        color: cs.error,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                        child: Text(
                                            _error!,
                                            style: TextStyle(
                                            color: cs.error,
                                            fontSize: 13,
                                            ),
                                        ),
                                        ),
                                    ],
                                    ),
                                ),
                                ],

                                const SizedBox(height: 14),

                                // Botón principal
                                SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                    ),
                                    ),
                                    onPressed:
                                        _loading ? null : _onSubmit,
                                    icon: _loading
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor:
                                                AlwaysStoppedAnimation<
                                                    Color>(
                                                Colors.white,
                                            ),
                                            ),
                                        )
                                        : const Icon(
                                            Icons.arrow_forward_rounded),
                                    label: Text(
                                    _loading ? 'Entrando…' : 'Entrar',
                                    ),
                                ),
                                ),

                                const SizedBox(height: 14),
                                Text(
                                '© ${DateTime.now().year} Carvajal Empaques',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                        color: cs.onSurfaceVariant,
                                    ),
                                ),
                            ],
                            ),
                        ),
                        ),
                    ),
                    ),
                ),
                ),
            ),
            ),
        ),
        );
    }
}

class _LogoHeader extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Image.asset(
        'assets/Logo_Carvajal.png',
        height: 86,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.08),
            shape: BoxShape.circle,
            ),
            child: Icon(
            Icons.all_inbox_rounded,
            size: 48,
            color: AppColors.primary,
            ),
        ),
        );
    }
}
