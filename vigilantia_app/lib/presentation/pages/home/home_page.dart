import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:vigilantia_app/shared/widgets/critical_alert_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showThermal = false;
  double _zoom = 5.0;
  late final MapController _mapController;
  LatLng? _currentLocation;
  bool _loading = true;

  String? _region;
  String? _icon;
  String? _country;
  double? _temperature;
  void _setupFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final alertId = message.data['alert_id'] ?? 'default_alert';
      print(message);
      SharedPreferences.getInstance().then((prefs) {
        final lastAlertId = prefs.getString('last_alert_id');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => CriticalAlertModal(
                title: message.notification?.title ?? 'INFORMATIVO',
                severity: message.data['severity'] ?? 'alerta',
                message: message.notification?.body ?? 'Mensagem recebida',
                footer: message.data['footer'] ?? 'Obrigado pela atenção!',
              ),
        );
        prefs.setString('last_alert_id', alertId);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _mapController = MapController();
    _getCurrentLocation();

    _setupFCMListener();
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _loading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _loading = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final newLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentLocation = newLocation;
      _loading = false;
    });

    await _fetchWeather(position.latitude, position.longitude);

    Future.delayed(const Duration(milliseconds: 300), () {
      _mapController.move(newLocation, _zoom);
    });
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    final apiKey = '3498eae2781f792524c23d00ea85c353';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=pt_br';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _temperature = data['main']['temp'];
        _region = data['name'];
        _icon = data['weather'][0]['icon'];
        _country = data['sys']['country'];

        print(
          'Temp: $_temperature | Icon: $_icon | Região: $_region | País: $_country',
        );
      });
    } else {
      print('Erro ao buscar clima: ${response.statusCode}');
    }
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF007777),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/user.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Alex Hage",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Data de nascimento: 11/11/1985",
                  style: TextStyle(color: Colors.white),
                ),
                Text("Cidade: Pará", style: TextStyle(color: Colors.white)),
                Text(
                  "Município: Ananindeua",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const Text("33 Anos", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo() {
    if (_temperature == null || _region == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF007777),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.network('https://openweathermap.org/img/wn/${_icon}.png'),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_temperature!.round()}°C",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                "País: $_country",
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                "Região: $_region",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation ?? LatLng(-14.2350, -51.9253),
              zoom: _zoom,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              // Mapa base neutro e clean
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.vigilantia',
              ),

              // Camada térmica da OpenWeatherMap
              if (showThermal)
                TileLayer(
                  urlTemplate:
                      'https://tile.openweathermap.org/map/temp_new/{z}/{x}/{y}.png?appid=3498eae2781f792524c23d00ea85c353',
                  userAgentPackageName: 'com.example.vigilantia',
                ),
            ],
          ),

          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  backgroundColor: const Color(0xFF1D4245),
                  onPressed: () {
                    setState(() {
                      _zoom += 1;
                      _mapController.move(_mapController.center, _zoom);
                    });
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  backgroundColor: const Color(0xFF1D4245),
                  onPressed: () {
                    setState(() {
                      _zoom -= 1;
                      _mapController.move(_mapController.center, _zoom);
                    });
                  },
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'toggle_thermal',
                  backgroundColor:
                      showThermal
                          ? Colors.orange.shade700
                          : const Color(0xFF1D4245),
                  onPressed: () {
                    setState(() {
                      showThermal = !showThermal;
                    });
                  },
                  child: const Icon(Icons.thermostat, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'go_to_location',
                  backgroundColor: const Color(0xFF1D4245),
                  onPressed: () {
                    if (_currentLocation != null) {
                      _mapController.move(_currentLocation!, _zoom);
                    }
                  },
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF035C5D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF007777),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : _currentLocation == null
              ? const Center(
                child: Text(
                  'Localização não disponível',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : Column(
                children: [
                  const SizedBox(height: 16),
                  _buildUserInfo(),
                  _buildWeatherInfo(),
                  _buildMapArea(),
                ],
              ),
    );
  }
}
