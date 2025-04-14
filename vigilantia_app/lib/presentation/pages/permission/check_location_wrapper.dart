import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class CheckLocationWrapper extends StatefulWidget {
  const CheckLocationWrapper({super.key});

  @override
  State<CheckLocationWrapper> createState() => _CheckLocationWrapperState();
}

class _CheckLocationWrapperState extends State<CheckLocationWrapper> {
  @override
  void initState() {
    super.initState();
    _verificarPermissao();
  }

  Future<void> _verificarPermissao() async {
    final prefs = await SharedPreferences.getInstance();
    final concedida = prefs.getBool('permissao_localizacao_concedida') ?? false;

    if (concedida) {
      context.go('/');
    } else {
      context.go('/location-permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
