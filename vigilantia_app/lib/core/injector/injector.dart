import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

class MyService {
  void sayHello() {
    print('Olá do serviço!');
  }
}

void setup() {
  sl.registerLazySingleton<MyService>(() => MyService());
}

Future<void> initializeDependencies() async {
  // Aqui você registra os serviços, use cases, repositórios, bloc, etc.
  // Exemplo:
  // sl.registerLazySingleton<MyService>(() => MyServiceImpl());
  setup();
  sl<MyService>().sayHello();
}
