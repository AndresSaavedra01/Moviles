import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';


void main() async {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'App Registro de Clases',
      debugShowCheckedModeBanner: false,

      // Configuración del tema global
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),

      // Configuración de GoRouter
      routerConfig: _router,
    );
  }
}


final GoRouter _router = GoRouter(
  initialLocation: '/',

  // Lógica de redirección para proteger rutas
  redirect: (BuildContext context, GoRouterState state) async {


    // Verificamos a qué pantalla intenta ir el usuario
    final bool isGoingToLogin = state.matchedLocation == '/login';
    final bool isGoingToRegister = state.matchedLocation == '/register';

    // 1. Si NO está logueado y NO va ni al login ni al registro, lo mandamos al login


    // 3. De lo contrario, dejar que continúe a donde iba
    return null;
  },

// En la configuración de rutas (dentro de routes: [...])

  routes: [
  ],
);