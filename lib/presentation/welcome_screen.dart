import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final Uri _instagramUrl =
      Uri.parse('https://www.instagram.com/unlugarchido_');
  final Uri _facebookUrl = Uri.parse(
      'https://www.facebook.com/profile.php?id=61555022528546&mibextid=LQQJ4d');

  int _tapCount = 0;
  DateTime? _lastTapTime;

  Future<void> _launchInstagram() async {
    if (!await launchUrl(_instagramUrl)) {
      throw Exception('No se pudo abrir $_instagramUrl');
    }
  }

  Future<void> _launchFacebook() async {
    if (!await launchUrl(_facebookUrl)) {
      throw Exception('No se pudo abrir $_facebookUrl');
    }
  }

  void _handleSecretGesture(BuildContext context) {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    if (_tapCount == 3) {
      _tapCount = 0;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).primaryColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () => _handleSecretGesture(context),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/logoChido.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              onPressed: () {
                context.go('/catalogo');
              },
              child: const Text('Ver Menú'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              onPressed: () {
                context.go('/qr');
              },
              child: const Text('Ver Código QR'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 131, 58, 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: _launchInstagram,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Síguenos en Instagram'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: _launchFacebook,
              icon: const Icon(Icons.facebook),
              label: const Text('Síguenos en Facebook'),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(height: 10),
            ),
          ],
        ),
      ),
    );
  }
}
