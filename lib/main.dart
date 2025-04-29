import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kalkulatorku/screens/loading_screen.dart';
import 'package:kalkulatorku/themes.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const KalkulatorKuApp(),
    ),
  );
}

class KalkulatorKuApp extends StatelessWidget {
  const KalkulatorKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'KalkulatorKu',
      themeMode: themeProvider.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const LoadingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
