import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vigilantia_app/shared/widgets/primary_button.dart';
import 'package:vigilantia_app/shared/widgets/top_alert.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;
  Future<void> _change_password(BuildContext context) async {
  try {
    if (_senhaController.text != _confirmarSenhaController.text) {
      // Exibe o alerta de senhas não iguais
      TopAlert.showTopAlert(
        context,
        "As senhas não coincidem!",
        "error",
      );
    } else {
      TopAlert.showTopAlert(
        context,
        "As senhas coincidem!",
        "info",
      );
      final prefs = await SharedPreferences.getInstance();
      final temp = prefs.getString('temp_reset_password');

      if (temp == null) {
          TopAlert.showTopAlert(context, 'Informações de recuperação não encontradas.', 'error');
          return;
        }

        final tempReset = jsonDecode(temp);
        final cpf = tempReset['cpf'];
        final codigo = tempReset['codigo'];

        if (cpf == null || codigo == null || _senhaController.text.isEmpty) {
          TopAlert.showTopAlert(context, 'Dados inválidos. Tente novamente.', 'error');
          return;
        }

        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/api/pessoa/alterar-senha'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'cpf': cpf,
            'codigo': codigo,
            'senha': _senhaController.text,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          TopAlert.showTopAlert(context, data['msg'] ?? 'Senha alterada com sucesso!', 'success');
          await prefs.remove('temp_reset_password');
          context.go('/');
        } else {
          TopAlert.showTopAlert(context, data['error'] ?? 'Erro ao alterar a senha.', 'error');
        }
      }
    
  } catch (e) {
    TopAlert.showTopAlert(context, 'Erro de conexão com o servidor.', 'error');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004D4D), // Fundo escuro
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF006666), // Card azul escuro
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                  'assets/images/vigilantia_logo_initial.png',
                  height: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Altere a sua senha',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Campo Nova Senha
              _buildTextField(
                label: 'Nova Senha',
                controller: _senhaController,
                obscureText: _obscureSenha,
                onToggleVisibility: () {
                  setState(() {
                    _obscureSenha = !_obscureSenha;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Campo Confirmar Senha
              _buildTextField(
                label: 'Confirmar Senha',
                controller: _confirmarSenhaController,
                obscureText: _obscureConfirmarSenha,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmarSenha = !_obscureConfirmarSenha;
                  });
                },
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                label: "Enviar",
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _change_password(context)
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
    );
  }

  static Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white24,
            hintText: 'Digite sua $label',
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
