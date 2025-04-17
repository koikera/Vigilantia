import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vigilantia_app/presentation/pages/change_password/change_password.dart';
import 'package:vigilantia_app/presentation/pages/permission/check_location_wrapper.dart';
import 'package:vigilantia_app/presentation/pages/permission/location_permission_page.dart';
import 'package:vigilantia_app/presentation/pages/register/register_page.dart';
import 'package:vigilantia_app/presentation/pages/home/home_page.dart';
import 'package:vigilantia_app/presentation/pages/login/login_page.dart';
import 'package:vigilantia_app/core/theme/app_theme.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vigilantia_app/presentation/pages/reset_password/reset_password.dart';
import 'package:vigilantia_app/presentation/pages/verify_code/verify_code.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user_data');

    if (jsonString != null) {
      final Map<String, dynamic> userData = jsonDecode(jsonString);
      final token = userData['access_token'];

      if (token != null && !JwtDecoder.isExpired(token)) {
        return '/home';
      }
    }

    return '/';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final initialRoute = snapshot.data!;

        final _router = GoRouter(
          initialLocation: initialRoute,
          routes: [
            GoRoute(path: '/', builder: (context, state) => const LoginPage()),
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => CustomTransitionPage(
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
                  final tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: Curves.ease));
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
            GoRoute(
              path: '/cadastro',
              builder: (context, state) => const CadastroPage(),
            ),
            GoRoute(
              path: '/redefinir-senha',
              builder: (context, state) => ResetPasswordPage(),
            ),
            GoRoute(
              path: '/verificar-codigo',
              builder: (context, state) => VerifyCodePage(),
            ),
            GoRoute(
              path: '/trocar-senha',
              builder: (context, state) => const ChangePasswordPage(),
            ),
          ],
        );

        return MaterialApp.router(
          title: 'Flutter App',
          theme: AppTheme.light,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
