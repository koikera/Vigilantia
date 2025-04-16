import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final cpfController = TextEditingController();
  final nomeController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final telefoneController = TextEditingController();
  final cepController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> buscarEndereco(String cep) async {
    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (!data.containsKey('erro')) {
        setState(() {
          ruaController.text = data['logradouro'] ?? '';
        });
      }
    }
  }

  Future<void> efetuarCadastro() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://10.0.2.2:3000/api/pessoa/create');
      final body = {
        "CPF": cpfController.text,
        "Nome_Completo": nomeController.text,
        "Data_Nascimento": dataNascimentoController.text,
        "Numero_Telefone": telefoneController.text,
        "CEP": cepController.text,
        "Rua": ruaController.text,
        "Numero": numeroController.text,
        "Complemento": complementoController.text,
        "Senha": senhaController.text,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro efetuado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cadastrar usuário.')),
        );
      }
    }
  }

  @override
  void dispose() {
    cpfController.dispose();
    nomeController.dispose();
    dataNascimentoController.dispose();
    telefoneController.dispose();
    cepController.dispose();
    ruaController.dispose();
    numeroController.dispose();
    complementoController.dispose();
    senhaController.dispose();
    super.dispose();
  }

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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/vigilantia_logo_initial.png',
                      height: 150,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Fique informado e protegido com alertas em tempo real.",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(context, "CPF", cpfController),
                    _buildTextField(context,"Nome Completo", nomeController),
                    _buildTextField(context,"Data de Nascimento", dataNascimentoController,
                      readOnly: true,
                      onChanged: (_) {},),
                    _buildTextField(context, "Número de Telefone", telefoneController),
                    _buildTextField(context,
                      "CEP",
                      cepController,
                      onChanged: (value) {
                        if (value.length == 8) buscarEndereco(value);
                      },
                    ),
                    _buildTextField(context, "Rua", ruaController, readOnly: true),
                    _buildTextField(context, "Número", numeroController),
                    _buildTextField(context, "Complemento", complementoController),
                    _buildTextField(context, "Senha", senhaController, obscureText: true),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: efetuarCadastro,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text("Efetuar Cadastro"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
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
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
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
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            readOnly: readOnly,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white),
            onTap: readOnly
                ? () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark(),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      String formattedDate =
                          "${pickedDate.day.toString().padLeft(2, '0')}/"
                          "${pickedDate.month.toString().padLeft(2, '0')}/"
                          "${pickedDate.year}";
                      controller.text = formattedDate;
                    }
                  }
                : null,
            decoration: InputDecoration(
              hintText: 'Digite seu $label',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white24,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

}
