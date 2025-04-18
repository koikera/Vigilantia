import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:vigilantia_app/shared/widgets/top_alert.dart';
import 'package:vigilantia_app/shared/widgets/custom_text_field.dart';

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
  final municipioController = TextEditingController();

  // Máscaras para os campos
  final cpfMask = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  final cepMask = MaskTextInputFormatter(mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});

  String? _validateCPF(String? value) {
    if (value == null || value.isEmpty) return 'Informe o CPF';
    if (value.length != 14) return 'CPF deve conter 11 dígitos (com máscara)';
    return null;
  }

  String? _validateTelefone(String? value) {
    if (value == null || value.isEmpty) return 'Informe o telefone';
    if (value.length < 14 || value.length > 15) return 'Número de telefone inválido';
    return null;
  }

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

  Future<void> efetuarCadastro(BuildContext context) async {
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
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        TopAlert.showTopAlert(
          context,
          "Cadastro efetuado com sucesso!",
          "success",
        );

        context.go('/');
      } else {
        TopAlert.showTopAlert(
          context,
          data['msg'],
          "error",
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
    municipioController.dispose();
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

                    // Campos usando CustomTextField
                    CustomTextField(
                      label: "CPF",
                      controller: cpfController,
                      validator: _validateCPF,
                      keyboardType: TextInputType.number,
                      inputFormatters: [cpfMask],
                    ),

                    CustomTextField(label: "Nome Completo", controller: nomeController),
                    CustomTextField(
                      label: "Data de Nascimento",
                      controller: dataNascimentoController,
                      readOnly: true,
                    ),
                    CustomTextField(
                      label: "Número de Telefone",
                      controller: telefoneController,
                      validator: _validateTelefone,
                      keyboardType: TextInputType.number,
                      inputFormatters: [telefoneMask],
                    ),

                    CustomTextField(
                      label: "CEP",
                      controller: cepController,
                      onChanged: (value) {
                        if (value.length == 9) buscarEndereco(value); // CEP com máscara
                      },
                      inputFormatters: [cepMask],
                    ),
                    CustomTextField(label: "Rua", controller: ruaController, readOnly: true),
                    CustomTextField(label: "Número", controller: numeroController),
                    CustomTextField(
                      label: "Complemento",
                      controller: complementoController,
                    ),
                    CustomTextField(label: "Senha", controller: senhaController, obscureText: true),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => efetuarCadastro(context),
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
}
