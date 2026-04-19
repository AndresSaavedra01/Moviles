import 'package:flutter/material.dart';
import 'taller_asincronia_screen.dart'; // Asegúrate de que el archivo anterior se llame así

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller Flutter Asincronía',
      debugShowCheckedModeBanner: false,

      // Configuración del tema inspirado en iOS 16 / Minimalista
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7), // Gris blanquecino Apple

        // Estilo de texto general
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          bodyMedium: TextStyle(color: Colors.black87),
        ),

        // Configuración global de los Cards
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),

        // Configuración de botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      home: const TallerAsincroniaScreen(),
    );
  }
}