import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class LocationPermissionPage extends StatelessWidget {
  const LocationPermissionPage({super.key});

  Future<void> _showPermissionModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 40, color: Colors.blue),
                const SizedBox(height: 10),
                const Text(
                  "O aplicativo Vigilantia precisa acessar a sua localização para funcionar corretamente.\nDeseja permitir?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity, // Ocupa a largura total disponível
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _requestPermission(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Permitir sempre",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, // Ocupa a largura total disponível
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _requestPermission(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 201, 201, 201),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Permitir durante o uso do app",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity, // Ocupa a largura total disponível
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 201, 201, 201),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Não permitir",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('permissao_localizacao_concedida', true);

      // redireciona para Login
      context.go('/');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Permissão não concedida.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF005E60),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Image.asset("assets/images/localization.png"),
              const SizedBox(height: 30),

              const Text(
                "Ative a localização para clima e alertas em tempo real",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Este aplicativo utiliza os dados de localização do seu dispositivo para oferecer uma experiência mais personalizada e eficiente. Com essas informações, conseguimos fornecer previsões precisas do clima na sua região, enviar alertas em tempo real sobre mudanças meteorológicas, além de disponibilizar diversos recursos úteis baseados na sua posição atual, como recomendações de vestuário, cuidados com o tempo e notificações sobre condições extremas. O acesso à localização é essencial para garantir que você receba as informações certas, no momento certo. Ao permitir o uso da sua localização, você estará ativando todas as funcionalidades do aplicativo e garantindo uma experiência completa, prática e segura.',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity, // Ocupa a largura total disponível
                child: ElevatedButton(
                  onPressed: () => _showPermissionModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Permitir",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
