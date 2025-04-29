import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

final sl = GetIt.instance;

class MyService {
  void sayHello() {
    print('Olá do serviço!');
  }
}

void setup() {
  // Registro do serviço como singleton
  sl.registerLazySingleton<MyService>(() => MyService());
}

Future<void> initializeDependencies() async {
  // Verifica a permissão de notificação e solicita, se necessário
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Chama a configuração do GetIt para inicializar dependências
  setup();

  // Chama o serviço após a inicialização das dependências
  sl<MyService>().sayHello();
}

