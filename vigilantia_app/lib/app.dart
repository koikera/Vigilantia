import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vigilantia_app/presentation/pages/permission/check_location_wrapper.dart';
import 'package:vigilantia_app/presentation/pages/permission/location_permission_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/login/login_page.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final _router = GoRouter(
      initialLocation: '/check-location',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/home',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const HomePage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: Curves.ease));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
        ),
        GoRoute(
          path: '/check-location',
          builder: (context, state) => const CheckLocationWrapper(),
        ),
        GoRoute(
          path: '/location-permission',
          builder: (context, state) => const LocationPermissionPage(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Flutter App',
      theme:
          AppTheme
              .light, // você pode criar o tema em /core/theme/app_theme.dart
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
