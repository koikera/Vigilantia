import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vigilantia_app/shared/widgets/custom_text_field.dart';
import 'package:vigilantia_app/shared/widgets/primary_button.dart';
import 'package:vigilantia_app/shared/widgets/top_alert.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final cpfMask = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final _cpfController = TextEditingController();
  String? _validateCPF(String? value) {
    if (value == null || value.isEmpty) return 'Informe o CPF';
    if (value.length != 14) return 'CPF deve conter 11 dígitos (com máscara)';
    return null;
  }
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  

  Future<void> _login(BuildContext context) async {
    final cpf = _cpfController.text.trim();
    final senha = _senhaController.text;

    if (cpf.isEmpty || senha.isEmpty) {
      TopAlert.showTopAlert(
                        context,
                        "Preencha todos os campos.",
                        "error",
                      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/pessoa/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cpf': cpf, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final refreshToken = data['refresh_token'];

        // Salva o refresh token localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('refresh_token', refreshToken);
        String jsonString = jsonEncode(data);
        await prefs.setString('user_data', jsonString);
        context.go('/home');
      } else {
        TopAlert.showTopAlert(context, 'CPF ou senha inválidos.', 'error');
      }
    } catch (e) {
      TopAlert.showTopAlert(context, 'Erro de conexão com o servidor.', 'error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF035C5D),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF007777),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/vigilantia_logo_initial.png',
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bem-vindo ao Vigilantia',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Fique informado e protegido com alertas em tempo real.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: "CPF",
                  controller: _cpfController,
                  validator: _validateCPF,
                  keyboardType: TextInputType.number,
                  inputFormatters: [cpfMask],
                ),
                const SizedBox(height: 16),
                CustomTextField(label: "Senha", controller: _senhaController, obscureText: true),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TextButton(
                        onPressed: () {
                          context.push('/cadastro');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Não tem uma conta?',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Flexible(
                      child: TextButton(
                        onPressed: () {
                          context.push('/redefinir-senha');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Esqueceu sua senha?',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: "Entrar",
                  icon:
                        _isLoading
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.arrow_forward),
                  onPressed: _isLoading ? null : () => _login(context),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Versão 0.0.1',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
