import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'core/injector/injector.dart';
import 'app.dart';
import 'shared/widgets/location_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Injeção de dependências
  await initializeDependencies();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettingsIos = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIos);


  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(const MyApp());

  Future.delayed(const Duration(seconds: 1), () async {
    await initializeService();
  });

  FlutterBackgroundService().invoke('setAsBackground');
}

Future<void> initializeService() async{
  final service = FlutterBackgroundService();
  debugPrint("Iniciando a configuração do serviço...");

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground
    ), 
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, 
      isForegroundMode: true, autoStart: true)
  );
  debugPrint("Serviço configurado. Iniciando...");

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // 🔥 Cria canal para notificação
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'background_channel',
    'Background Service',
    description: 'Serviço rodando em background',
    importance: Importance.low,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  if (service is AndroidServiceInstance) {
    await service.setAsForegroundService();

    // 🔥 Apenas uma notificação de serviço rodando
    const AndroidNotificationDetails foregroundNotificationDetails =
        AndroidNotificationDetails(
      'background_channel',
      'Background Service',
      channelDescription: 'Serviço rodando em background',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true, // Para manter o serviço vivo
    );

    const NotificationDetails foregroundNotification =
        NotificationDetails(android: foregroundNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Serviço iniciado',
      'Aguardando novas mensagens...',
      foregroundNotification,
    );

    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
    initializeService(); // Reinicia o serviço caso ele pare inesperadamente
  });

  // 🔥 Conecta Socket.IO
  final socket = IO.io(
    'http://10.0.2.2:3000',
    <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    },
  );

  socket.connect();

  socket.onConnect((_) {
    debugPrint('Socket conectado no background!');
  });

  socket.onDisconnect((_) {
    debugPrint('Socket desconectado no background!');
  });

  socket.onError((error) {
    debugPrint('Erro no socket: $error');
  });

  // 🔥 Mensagem recebida
  socket.on('mensagem', (data) async {
    try {
      final alertRegion = (data['regiao'] ?? '').toString().toLowerCase();
      final alertState = (data['estado'] ?? '').toString().toLowerCase();
      final alertId = data['alert_id'] ?? 'default_alert';
      final severity = data['severity'] ?? 'alerta';
      final title = data['title'] ?? 'INFORMATIVO';
      final body = data['body'] ?? 'Mensagem recebida';
      final footer = data['footer'] ?? 'Obrigado pela atenção!';

      final userRegion = ('sudeste').toString().toLowerCase();
      final userState = ('são paulo').toString().toLowerCase();

      if (userRegion.contains(alertRegion) || alertRegion == 'todas') {
        if (userState.contains(alertState)) {
          print('Nova mensagem recebida!');

          // 🔥 Notificação de mensagem
          const AndroidNotificationDetails popupNotificationDetails =
              AndroidNotificationDetails(
            'popup_channel',
            'Notificações Popups',
            channelDescription: 'Alertas importantes recebidos via socket',
            importance: Importance.high,
            priority: Priority.high,
          );

          const NotificationDetails popupNotification =
              NotificationDetails(android: popupNotificationDetails);

          await flutterLocalNotificationsPlugin.show(
            alertId.hashCode,
            title,
            '$body\n\n$footer',
            popupNotification,
          );
        } else {
          print('Mensagem ignorada: estado diferente.');
        }
      } else {
        print('Mensagem ignorada: região diferente.');
      }
    } catch (e) {
      print('Erro ao processar mensagem: $e');
    }
  });

  // 🔥 Pingar o servidor de tempos em tempos só para manter a conexão aberta (sem notificar o usuário)
  Timer.periodic(const Duration(seconds: 25), (_) {
    if (socket.connected) {
      socket.emit('ping', {});
      debugPrint('Ping enviado para manter conexão');
    }
    service.invoke('update'); // importante pro Android ver que está "ativo"
  });
}