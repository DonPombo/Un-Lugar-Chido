import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactoScreen extends StatelessWidget {
  const ContactoScreen({super.key});

  Future<void> _lanzarURL(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'No se pudo abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Un Lugar Chido',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor),
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.center,
              image: const AssetImage('assets/images/logoChido.png'),
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.8),
                BlendMode.lighten,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Horario de atención:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Martes a Domingos: 9:00 AM - 11:00 PM',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¡Conéctate con nosotros!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              _botonRedSocial(
                context,
                'Instagram',
                const Icon(Icons.camera_alt),
                'https://www.instagram.com/turestaurante',
                const Color.fromARGB(
                    255, 131, 58, 180), // Color oficial de Instagram
              ),
              const SizedBox(height: 10),
              _botonRedSocial(
                context,
                'Facebook',
                const Icon(Icons.facebook),
                'https://www.facebook.com/turestaurante',
                const Color(0xFF1877F2), // Color oficial de Facebook
              ),
              const SizedBox(height: 10),
              _botonRedSocial(
                context,
                'WhatsApp',
                Image.asset(
                  'assets/images/whatsApp.png',
                  width: 24,
                  height: 24,
                ),
                'https://wa.me/1234567890',
                const Color(0xFF25D366), // Color oficial de WhatsApp
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Ver ubicación en el mapa'),
                onPressed: () =>
                    _lanzarURL(Uri.parse('https://goo.gl/maps/turestaurante')),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _botonRedSocial(BuildContext context, String nombre, Widget icono,
      String url, Color colorFondo) {
    return ElevatedButton.icon(
      icon: icono,
      label: Text('Síguenos en $nombre'),
      onPressed: () => _lanzarURL(Uri.parse(url)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: colorFondo, // Aplicar color de fondo personalizado
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
