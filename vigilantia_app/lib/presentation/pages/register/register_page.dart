import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final cpfController = TextEditingController();
  final nomeController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final telefoneController = TextEditingController();
  final cepController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();
  final senhaController = TextEditingController();

  // Busca endereço no ViaCEP
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

  // Envia dados para a API
  Future<void> efetuarCadastro() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://127.0.0.1:3000/api/pessoa/create');
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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro efetuado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao cadastrar usuário.')));
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
      backgroundColor: Color(0xFF005E60),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset("assets/logo.png", height: 80), // sua logo aqui
                    SizedBox(height: 10),
                    Text(
                      "Vigilantia",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Fique informado e protegido com alertas em tempo real.",
                    ),
                    SizedBox(height: 20),

                    _buildTextField("CPF", cpfController),
                    _buildTextField("Nome Completo", nomeController),
                    _buildTextField(
                      "Data de nascimento",
                      dataNascimentoController,
                    ),
                    _buildTextField("Número de Telefone", telefoneController),
                    _buildTextField(
                      "CEP",
                      cepController,
                      onChanged: (value) {
                        if (value.length == 8) buscarEndereco(value);
                      },
                    ),
                    _buildTextField("Rua", ruaController, readOnly: true),
                    _buildTextField("Número", numeroController),
                    _buildTextField("Complemento", complementoController),
                    _buildTextField(
                      "Senha",
                      senhaController,
                      obscureText: true,
                    ),

                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: efetuarCadastro,
                      icon: Icon(Icons.arrow_forward),
                      label: Text("Efetuar Cadastro"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Versão 0.0.1",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo obrigatório';
          }
          return null;
        },
      ),
    );
  }
}
