import 'package:flutter/material.dart';
import 'package:un_lugar_chido_app/pages/screens.dart';
import 'package:go_router/go_router.dart';
import 'package:un_lugar_chido_app/admin%20screens/login_screen.dart';
import 'package:un_lugar_chido_app/admin%20screens/panel_admin_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const HomePage(),
      ),
    ),
    GoRoute(
      path: '/catalogo',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CatalogoMenuScreen(),
      ),
    ),
    GoRoute(
      path: '/qr',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const QRScreen(),
      ),
    ),
    GoRoute(
      path: '/contacto',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const ContactoScreen(),
      ),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) {
        print('Creando página del panel admin'); // Debug
        return MaterialPage(
          key: state.pageKey,
          child: const PanelAdminScreen(),
        );
      },
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),
  ],
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  ),
);
