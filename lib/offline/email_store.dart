import 'package:shared_preferences/shared_preferences.dart';

class EmailStore {
    static const _kLastEmail = 'last_login_email';
    static const _kRemember  = 'last_login_remember';

    Future<void> save({required String email, required bool remember}) async {
        final sp = await SharedPreferences.getInstance();
        await sp.setBool(_kRemember, remember);
        if (remember) {
        await sp.setString(_kLastEmail, email);
        } else {
        await sp.remove(_kLastEmail);
        }
    }

    /// Devuelve (email, remember)
    Future<({String? email, bool remember})> load() async {
        final sp = await SharedPreferences.getInstance();
        final remember = sp.getBool(_kRemember) ?? true; // por defecto ON
        final email    = remember ? sp.getString(_kLastEmail) : null;
        return (email: email, remember: remember);
    }

    Future<void> clear() async {
        final sp = await SharedPreferences.getInstance();
        await sp.remove(_kLastEmail);
        await sp.remove(_kRemember);
    }
}
