import 'package:flutter/material.dart';
import 'core/injector/injector.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Solicita permissão (necessário em iOS e Android 13+)
  NotificationSettings settings = await messaging.requestPermission();

  print('Permissão concedida: ${settings.authorizationStatus}');

  // Token do dispositivo (para testes ou associar no backend)
  final token = await messaging.getToken();
  print("FCM Token: $token");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();
  await setupFCM();
  // Injeção de dependências
  await initializeDependencies();

  // Configura o handler para notificações em segundo plano
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Mensagem recebida em foreground: ${message.notification?.title}');
    // Aqui você pode chamar um modal, por exemplo:
    // showDialog(...)
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Usuário abriu a notificação: ${message.notification?.title}');
  });

  runApp(const MyApp());
}

// Handler para receber mensagens enquanto o app está em segundo plano ou fechado
Future<void> backgroundHandler(RemoteMessage message) async {
  print('Mensagem recebida em segundo plano: ${message.messageId}');
}
