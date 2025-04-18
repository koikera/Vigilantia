import 'package:flutter/material.dart';
import 'core/injector/injector.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();

  // Injeção de dependências
  await initializeDependencies();

  // Configura o handler para notificações em segundo plano
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  // Listener para notificações recebidas com o app aberto (foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📩 Mensagem recebida em foreground: ${message.notification?.title}');
    // Você pode chamar um modal ou exibir um snackbar aqui se quiser
  });

  // Quando o usuário abre o app clicando em uma notificação
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📬 Usuário abriu a notificação: ${message.notification?.title}');
    // Pode redirecionar para uma tela específica aqui, se necessário
  });

  runApp(const MyApp());
}

// Handler para mensagens recebidas em segundo plano ou com o app fechado
Future<void> backgroundHandler(RemoteMessage message) async {
  print('📡 Mensagem recebida em segundo plano: ${message.messageId}');
}
