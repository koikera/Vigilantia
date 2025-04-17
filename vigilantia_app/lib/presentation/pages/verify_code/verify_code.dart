import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:vigilantia_app/shared/widgets/primary_button.dart';

class VerifyCodePage extends StatelessWidget {
  const VerifyCodePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF005E60),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            color: const Color(0xFF007777),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/vigilantia_logo_initial.png',
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Acabamos de enviar um código para o seu celular",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Insira no campo abaixo o código de verificação de 6 dígitos enviado para o seu telefone",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    animationType: AnimationType.fade,
                    keyboardType: TextInputType.number,
                    textStyle: const TextStyle(color: Colors.white),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(6),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      inactiveFillColor: Colors.white24,
                      activeFillColor: Colors.white24,
                      selectedFillColor: Colors.white24,
                      activeColor: Colors.white,
                      selectedColor: Colors.white,
                      inactiveColor: Colors.white,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    onChanged: (value) {
                      // código inserido
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // lógica para reenviar código
                    },
                    child: const Text(
                      "Reenviar código",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: "Proximo",
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                        context.go('/trocar-senha');
                      },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Dica: Caso não encontre o código, verifique a pasta de Spam!",
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Versão 0.0.1",
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
