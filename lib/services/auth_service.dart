import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> iniciarSesion(String email, String password) async {
    try {
      print('Intentando iniciar sesión con: $email');

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('Login exitoso para: ${response.user?.email}');
        return true;
      } else {
        print('Login fallido: usuario null');
        return false;
      }
    } catch (e) {
      print('Error detallado al iniciar sesión: $e');
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    await _supabase.auth.signOut();
  }

  User? get usuarioActual => _supabase.auth.currentUser;
}
