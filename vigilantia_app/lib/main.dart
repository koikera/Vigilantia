import 'package:flutter/material.dart';
import 'core/injector/injector.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Injeção de dependências
  await initializeDependencies();

  runApp(const MyApp());
}
