import 'dart:convert';

import 'package:geocoding/geocoding.dart' as geo;
import 'package:http/http.dart' as http;

Future<String?> getApproximateCep(double latitude, double longitude) async {
  try {
    // Realiza a geocodificação reversa usando latitude e longitude
    List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      // Retorna o CEP do primeiro placemark
      return placemarks.first.postalCode;
    } else {
      return null;  // Caso não encontre nenhum endereço
    }
  } catch (e) {
    print('Erro ao obter CEP: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> buscarEnderecoViaCep(String cep) async {
  try {
    final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (!data.containsKey('erro')) {
        return data;
      }
    }
  } catch (e) {
    print('Erro ao buscar endereço: $e');
  }
  return null;
}