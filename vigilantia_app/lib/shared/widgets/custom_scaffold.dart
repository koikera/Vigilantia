import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget> drawerItems;

  const CustomScaffold({
    super.key,
    required this.body,
    this.drawerItems = const [],
  });

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
            const SizedBox(width: 8),
          ],
        ),
      ),
      endDrawer: Drawer(
        backgroundColor: const Color(0xFF1D4245),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Color.fromARGB(255, 123, 149, 151),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(Icons.list, color: Color.fromARGB(255, 123, 149, 151)),
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o drawer
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: drawerItems,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('user_data');

                    context.go('/');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    foregroundColor: Colors.white,
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  icon: Icon(Icons.logout),
                  label: Text(
                    'Sair',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      body: body,
    );
  }
}
