
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vigilantia_app/shared/widgets/custom_text_field.dart';
import 'package:vigilantia_app/shared/widgets/primary_button.dart';
import 'package:vigilantia_app/shared/widgets/top_alert.dart';

class ResetPasswordPage extends StatelessWidget {
  final cpfMask = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  String? _validateCPF(String? value) {
    if (value == null || value.isEmpty) return 'Informe o CPF';
    if (value.length != 14) return 'CPF deve conter 11 dígitos (com máscara)';
    return null;
  }
  final TextEditingController cpfController = TextEditingController();

  ResetPasswordPage({super.key});

  Future<void> _verify_cpf(BuildContext context) async {
    try {
      TopAlert.showTopAlert(context, 'Estamos validando seu CPF, por favor, aguarde.' , 'info');
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/pessoa/esqueceu-senha'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cpf': cpfController.text}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final refreshToken = data['refresh_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cpf_temp', cpfController.text);
        TopAlert.showTopAlert(context, data['msg'], 'success');

        context.go('/verificar-codigo');

      } else {
        TopAlert.showTopAlert(context, data['error'], 'error');
      }
    } catch (e) {
      TopAlert.showTopAlert(context, 'Erro de conexão com o servidor.', 'error');
    } finally {
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF005E60),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            color: const Color(0xFF007777),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/vigilantia_logo_initial.png',
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Esqueceu a senha?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Redefina a senha em duas etapas",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: "Qual é o CPF cadastrado?",
                    controller: cpfController,
                    validator: _validateCPF,
                    keyboardType: TextInputType.number,
                    inputFormatters: [cpfMask],
                    hintText: 'Digite o seu CPF',
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: "Proximo",
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _verify_cpf(context),
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
