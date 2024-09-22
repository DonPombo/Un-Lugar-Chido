import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/screens.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _error = '';

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: FadeTransition(
                opacity: _animation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.restaurant_menu,
                        size: 100,
                        color: themeData.primaryColor,
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: themeData.primaryColor),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: themeData.primaryColor),
                          ),
                        ),
                        validator: (val) => val!.isEmpty ? 'Ingresa un email' : null,
                        onChanged: (val) => setState(() => _email = val),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock, color: themeData.primaryColor),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: themeData.primaryColor),
                          ),
                        ),
                        obscureText: true,
                        validator: (val) => val!.length < 6 ? 'La contraseña debe tener al menos 6 caracteres' : null,
                        onChanged: (val) => setState(() => _password = val),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: themeData.colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            bool result = await _auth.iniciarSesion(_email, _password);
                            if (result) {
                              // ignore: use_build_context_synchronously
                              context.go('/admin');
                            } else {
                              setState(() => _error = 'No se pudo iniciar sesión. Verifica tus credenciales.');
                            }
                          }
                        },
                        child: const Text('Iniciar Sesión'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red, fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ],
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