import 'package:flutter/material.dart';

class TopAlert extends StatelessWidget {
  final String message;
  final String type;
  
  const TopAlert({
    super.key,
    required this.message,
    required this.type,
  });

  // Função para retornar a cor de fundo de acordo com o tipo
  Color _getBackgroundColor() {
    switch (type) {
      case 'error':
        return Colors.red.shade700;
      case 'success':
        return Colors.green;
      case 'info':
      default:
        return Colors.blue; // Azul claro
    }
  }

  // Função para mostrar o TopAlert
  static void showTopAlert(BuildContext context, String message, String type) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: TopAlert(type: type, message: message)._getBackgroundColor(), // Usando a função _getBackgroundColor
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  type == 'error' ? Icons.error_outline : Icons.info_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Retorne algo, já que esse widget não precisa exibir nada diretamente.
  }
}

// Exemplo de como usar o TopAlert globalmente:
void showCustomAlert(BuildContext context, String message, String type) {
  TopAlert.showTopAlert(context, message, type);
}
