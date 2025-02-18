import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';

class UsuarioService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> registrarUsuario(Usuario usuario) async {
    try {
      // Registrar en auth
      final authResponse = await _supabase.auth.signUp(
        email: usuario.email,
        password: usuario.password,
      );

      if (authResponse.user == null) {
        throw Exception('Error al registrar usuario');
      }

      // Guardar en la tabla usuarios (el trigger hasheará la contraseña)
      await _supabase.from('usuarios').insert({
        'email': usuario.email,
        'nombre': usuario.nombre,
        'password': usuario.password,
      });
    } catch (e) {
      print('Error al registrar usuario: $e');
      throw e;
    }
  }

  Future<void> actualizarUsuario(Usuario usuario) async {
    try {
      if (usuario.id == null)
        throw Exception('ID del usuario no puede ser null');
      await _supabase
          .from('usuarios')
          .update(usuario.toMap())
          .eq('id', usuario.id!);
    } catch (e) {
      print('Error al actualizar usuario: $e');
      throw e;
    }
  }

  Stream<List<Map<String, dynamic>>> getUsuariosStream() {
    return _supabase
        .from('usuarios')
        .stream(primaryKey: ['id']).map((event) => event);
  }

  Future<void> desactivarUsuario(String id) async {
    try {
      await _supabase.from('usuarios').update({'activo': false}).eq('id', id);
    } catch (e) {
      print('Error al desactivar usuario: $e');
      throw e;
    }
  }

  // Método para iniciar sesión
  Future<User?> iniciarSesion(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Credenciales inválidas');
      }

      return response.user;
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('Email o contraseña incorrectos');
      } else {
        throw Exception('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      print('Error detallado: $e');
      throw Exception('Error al iniciar sesión. Por favor, intente de nuevo.');
    }
  }

  // Método para cerrar sesión
  Future<void> cerrarSesion() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
      throw e;
    }
  }
}
