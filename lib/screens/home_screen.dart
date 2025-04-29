import 'package:flutter/material.dart';
import 'package:kalkulatorku/screens/about_screen.dart';
import 'package:kalkulatorku/screens/calculator_screen.dart';
import 'package:provider/provider.dart';
import 'package:kalkulatorku/themes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menampilkan logo dari assets
            Image.asset(
              'assets/icon.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 50), // Jarak antara logo dan tombol

            ElevatedButton(
              child: const Text('Buka Kalkulator'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalculatorScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Tentang'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
