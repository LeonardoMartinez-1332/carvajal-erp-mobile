import 'dart:io'; //para detectar plataforma

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/app_theme.dart';
import 'core/routes.dart';

// Auth / Splash
import 'modules/auth/login_page.dart';
import 'modules/auth/splash_page.dart';

// Homes por rol
import 'modules/home/user_home.dart';
import 'modules/home/supervisor_home.dart';
import 'modules/home/admin_home.dart';
import 'modules/home/jobs_home.dart';

// Módulos de Jobs
import 'pages/jobs/jobs_nueva_ti_page.dart';
import 'pages/jobs/jobs_historial_ti_page.dart';
import 'pages/jobs/jobs_reportes_page.dart';
import 'pages/jobs/jobs_detalle_ti_page.dart';

// Módulos del supervisor
import 'pages/supervisor/consulta_productos_page.dart';
import 'pages/supervisor/bitacora_page.dart';

// Módulos del admin
import 'pages/admin/usuarios_page.dart';
import 'models/admin_user.dart';
import 'models/product.dart';
import 'pages/admin/admin_usuario_form_page.dart';
import 'pages/admin/catalogo_productos_page.dart';
import 'pages/admin/dashboard_page.dart';
import 'pages/admin/logs_page.dart';
import 'pages/admin/settings_page.dart';
import 'pages/admin/mantenimiento_page.dart';
import 'pages/admin/solicitudes_admin_page.dart';
import 'pages/admin/solicitudes_desbloqueo_page.dart';
import 'pages/admin/producto_form_page.dart';

// Módulos del usuario
import 'pages/user/user_profile_page.dart';
import 'pages/user/user_help_page.dart';
// Notificaciones
import '../pages/notifications_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inicializar sqflite para ESCRITORIO (Windows / Linux / macOS)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const ERPApp());
}

class ERPApp extends StatelessWidget {
  const ERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ERP Carvajal',
      theme: AppTheme.light(),
      initialRoute: RoutePaths.splash,
      routes: {
        // Auth
        RoutePaths.splash: (_) => const SplashPage(),
        RoutePaths.login: (_) => const LoginPage(),

        // Homes por rol
        RoutePaths.homeUser: (_) => const UserHome(),
        RoutePaths.homeSupervisor: (_) => const SupervisorHome(),
        RoutePaths.homeAdmin: (_) => const AdminHome(),
        RoutePaths.homeJobs: (_) => const JobsHome(),

        // Supervisor
        RoutePaths.supConsulta: (_) => const ConsultaProductosPage(),
        RoutePaths.supBitacora: (_) => const BitacoraPage(),

        // Admin
        RoutePaths.adminUsuarios: (_) => const AdminUsuariosPage(),
        RoutePaths.adminNuevoUsuario: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          final user = args is AdminUser ? args : null;
          return AdminUsuarioFormPage(usuario: user);
        },
        RoutePaths.adminProductos: (_) =>
            const AdminCatalogoProductosPage(),

        // Form de productos (nuevo / editar)
        RoutePaths.adminProductoForm: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          final product = args is Product ? args : null;
          return ProductoFormPage(product: product);
        },

        RoutePaths.adminDashboard: (_) => const AdminDashboardPage(),
        RoutePaths.adminLogs: (_) => const AdminLogsPage(),
        RoutePaths.adminSettings: (_) => const AdminSettingsPage(),
        RoutePaths.adminMantenimiento: (_) =>
            const AdminMantenimientoPage(),
        RoutePaths.adminSolicitudes: (_) =>
            const AdminSolicitudesPage(),
        RoutePaths.adminSolicitudesDesbloqueo: (_) =>
            const AdminSolicitudesDesbloqueoPage(),

        // Jobs
        RoutePaths.jobsNuevaTi: (_) => const JobsNuevaTiPage(),
        RoutePaths.jobsHistorialTi: (_) => const JobsHistorialTiPage(),
        RoutePaths.jobsDetalleTi: (_) => const JobsDetalleTiPage(),
        RoutePaths.jobsReportes: (_) => const JobsReportesPage(),

        // User
        RoutePaths.userProfile: (_) => const UserProfilePage(),
        RoutePaths.userHelp: (_) => const UserHelpPage(),

        // Notificaciones 
        RoutePaths.notificaciones: (context) => const NotificationsPage(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) =>
            _FallbackRoute(name: settings.name ?? 'desconocida'),
      ),
    );
  }
}

void goToPanel(BuildContext context, String rawRole) {
  final r = rawRole.trim().toLowerCase();

  final route = (r == 'superusuario' || r == 'admin' || r == 'administrator')
      ? RoutePaths.homeAdmin
      : (r == 'supervisor')
          ? RoutePaths.homeSupervisor
          : (r == 'jobs')
              ? RoutePaths.homeJobs
              : RoutePaths.homeUser;

  Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
}

class _FallbackRoute extends StatelessWidget {
  const _FallbackRoute({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    const adminBar = Color(0xFF37474F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: adminBar,
        foregroundColor: Colors.white,
        title: const Text('Ruta no encontrada'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No existe la ruta: $name',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
