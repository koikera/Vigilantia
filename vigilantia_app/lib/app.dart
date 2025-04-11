import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/login/login_page.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final _router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const HomePage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0); // Da direita para a esquerda
                const end = Offset.zero;
                const curve = Curves.ease;

                final tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                final offsetAnimation = animation.drive(tween);

                return SlideTransition(position: offsetAnimation, child: child);
              },
            );
          },
        ),

        // Adicione outras rotas aqui
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
