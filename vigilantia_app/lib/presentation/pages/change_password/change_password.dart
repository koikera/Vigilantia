import 'package:flutter/material.dart';
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
                onPressed: () {
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
                  }
                }
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
