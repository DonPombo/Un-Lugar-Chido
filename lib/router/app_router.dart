import 'package:flutter/material.dart';
import 'package:un_lugar_chido_app/presentation/screens.dart';
import 'package:go_router/go_router.dart';

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
        child: CatalogoMenuScreen(),
      ),
    ),
    GoRoute(
      path: '/qr',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const QRScreen(),
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
