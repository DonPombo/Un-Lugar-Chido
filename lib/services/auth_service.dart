import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> iniciarSesion(String email, String password) async {
    try {
      UserCredential resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      User? usuario = resultado.user;
      if (usuario != null) {
        DocumentSnapshot doc = await _firestore.collection('usuarios').doc(usuario.uid).get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String rol = data['rol'];
          return rol == 'admin' || rol == 'trabajador';
        }
      }
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // Método para crear un nuevo usuario (solo para uso administrativo)
  Future<bool> crearUsuario(String email, String password, String nombre, String rol) async {
    try {
      UserCredential resultado = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      User? usuario = resultado.user;
      if (usuario != null) {
        await _firestore.collection('usuarios').doc(usuario.uid).set({
          'nombre': nombre,
          'email': email,
          'rol': rol,
        });
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}