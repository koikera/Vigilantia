// lib/shared/widgets/critical_alert_modal.dart
import 'package:flutter/material.dart';

class CriticalAlertModal extends StatelessWidget {
  final String title;
  final String message;
  final String footer;
  final String severity; // ex: "info", "alerta", "emergencia"

  const CriticalAlertModal({
    super.key,
    required this.title,
    required this.message,
    required this.footer,
    required this.severity,
  });

  Color _getBackgroundColor() {
    switch (severity) {
      case 'emergencia':
        return Colors.red.shade700;
      case 'alerta':
        return Colors.orange.shade600;
      case 'info':
      default:
        return const Color(0xFFCCE1E8); // azul claro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Color.fromARGB(255, 29, 66, 69),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(
              255,
              29,
              66,
              69,
            ), // cor da borda (fundo branco)
            borderRadius: BorderRadius.circular(20), // bordas arredondadas
            border: Border.all(width: 2.0, color: const Color(0xFFFFFFFF)),
          ),
          padding: const EdgeInsets.all(
            16,
          ), // padding interno dentro da "borda"
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 233, 227, 140), // fundo amarelo
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "SECRETARIA DE OBRAS",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Image.asset('assets/images/ananindeua.png'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
