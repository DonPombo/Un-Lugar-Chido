import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/screens.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _error = '';
  bool _obscureText = true;
  bool _isLoading = false;

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

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fondo neutro
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
                        color:
                            themeData.primaryColor, // Color primario del ícono
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Iniciar Sesión',
                        textAlign: TextAlign.center,
                        style: themeData.textTheme
                            .displayLarge, // Título con estilo del tema
                      ),
                      const SizedBox(height: 40),
                      _buildTextField(
                        label: 'Email',
                        icon: Icons.email,
                        onChanged: (val) => setState(() => _email = val),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Contraseña',
                        icon: Icons.lock,
                        isPassword: true,
                        onChanged: (val) => setState(() => _password = val),
                      ),
                      const SizedBox(height: 40),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    themeData.colorScheme.secondary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5, // Sombra para el botón
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    bool result = await _auth.iniciarSesion(
                                        _email, _password);
                                    if (result) {
                                      context.go('/admin');
                                    } else {
                                      setState(() {
                                        _error =
                                            'Credenciales inválidas. Por favor, inténtalo de nuevo.';
                                        _isLoading = false;
                                      });
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _error =
                                          'Error de conexión. Por favor, inténtalo más tarde.';
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                              child: const Text('Iniciar Sesión'),
                            ),
                      const SizedBox(height: 12),
                      Text(
                        _error,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14.0),
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    bool isPassword = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: themeData.primaryColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: themeData.primaryColor,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white, // Fondo blanco para el campo de texto
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: themeData.primaryColor, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: themeData.primaryColor, width: 2.0),
        ),
      ),
      obscureText: isPassword ? _obscureText : false,
      validator: (val) => val!.isEmpty ? 'Por favor, ingresa $label' : null,
      onChanged: onChanged,
    );
  }
}
