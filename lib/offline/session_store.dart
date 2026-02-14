import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  // Claves
    static const _kToken = 'auth_token';
    static const _kRole = 'auth_role';
    static const _kUserName = 'auth_username';
    static const _kLastLoginAt = 'auth_last_login_at_epoch_ms';

    // Token seguro
    static const FlutterSecureStorage _secure = FlutterSecureStorage();

    /// Guarda token (seguro) + datos no sensibles + timestamp
    Future<void> saveSession({
        required String token,
        required String role,
        required String userName,
    }) async {
        final sp = await SharedPreferences.getInstance();
        await _secure.write(key: _kToken, value: token);
        await sp.setString(_kRole, role);
        await sp.setString(_kUserName, userName);
        await markLoginNow();
    }

    /// Marca "último login = ahora"
    Future<void> markLoginNow() async {
        final sp = await SharedPreferences.getInstance();
        await sp.setInt(_kLastLoginAt, DateTime.now().millisecondsSinceEpoch);
    }

    /// Epoch en ms del último login (o null si no existe)
    Future<int?> get lastLoginAtMs async =>
        (await SharedPreferences.getInstance()).getInt(_kLastLoginAt);

    /// ¿La sesión está vieja según [maxAge]?
    Future<bool> isSessionStale(Duration maxAge) async {
        final ms = await lastLoginAtMs;
        if (ms == null) return true;
        final last = DateTime.fromMillisecondsSinceEpoch(ms);
        return DateTime.now().difference(last) > maxAge;
    }

    // Lecturas comunes
    Future<String?> get token async => await _secure.read(key: _kToken);
    Future<String?> get role async =>
        (await SharedPreferences.getInstance()).getString(_kRole);
    Future<String?> get userName async =>
        (await SharedPreferences.getInstance()).getString(_kUserName);

    /// Limpia todo
    Future<void> clear() async {
        final sp = await SharedPreferences.getInstance();
        await _secure.delete(key: _kToken);
        await sp.remove(_kRole);
        await sp.remove(_kUserName);
        await sp.remove(_kLastLoginAt);
    }

    /// Migración opcional (si alguna vez guardaste token en SharedPreferences)
    Future<void> migrateIfNeeded() async {
        final sp = await SharedPreferences.getInstance();
        final old = sp.getString(_kToken);
        if (old != null && (await _secure.read(key: _kToken)) == null) {
        await _secure.write(key: _kToken, value: old);
        await sp.remove(_kToken);
        }
    }
}
