
class RoutePaths {
  // Auth
    static const splash = '/splash';
    static const login  = '/';

    // Homes
    static const homeUser        = '/home/user';
    static const homeSupervisor  = '/home/supervisor';
    static const homeAdmin       = '/home/admin';
    static const homeJobs        = '/home/jobs';


    // Supervisor
    static const supConsulta  = '/supervisor/consulta';
    static const supBitacora  = '/supervisor/bitacora';

    // Admin
    static const adminUsuarios       = '/admin/usuarios';
    static const adminNuevoUsuario   = '/admin/usuarios/nuevo';
    static const adminUsuariosListado = '/admin/usuarios/listado';
    static const adminProductos      = '/admin/productos';
    static const adminDashboard      = '/admin/dashboard';
    static const adminLogs           = '/admin/logs';
    static const adminSettings       = '/admin/settings';
    static const adminMantenimiento  = '/admin/mantenimiento';
    static const adminSolicitudes = '/admin/solicitudes';
    static const adminSolicitudesDesbloqueo ='/admin/solicitudes-desbloqueo';
    static const adminProductoForm = '/admin/productos/form';

    // Jobs
    static const jobsNuevaTi     = '/jobs/ti/nueva';
    static const jobsHistorialTi = '/jobs/ti/historial';
    static const jobsReimpresion = '/jobs/ti/reimpresion';
    static const jobsDetalleTi    = '/jobs/ti/detalle';
    static const jobsReportes = '/jobs/reportes';


    // User
    static const userProfile = '/user/perfil';
    static const userHelp    = '/user/ayuda';

    static const notificaciones = '/notificaciones';
}
