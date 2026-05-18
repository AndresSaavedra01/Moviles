import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_jwt/views/categoria_fb/universidad_fb_form_view.dart';
import 'package:taller_jwt/views/categoria_fb/universidad_fb_list_view.dart';


import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'App Registro de Clases',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
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
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}

// ================= ROUTER =================

final GoRouter appRouter = GoRouter(
  initialLocation: '/universidadesfb', // Actualizado

  routes: [

    // ================= LISTAR =================
    GoRoute(
      path: '/universidadesfb',
      name: 'universidadesfb',
      builder: (context, state) {
        return const UniversidadFbListView();
      },
    ),

    // ================= CREAR =================
    GoRoute(
      path: '/universidadesfb/create',
      name: 'universidadesfb.create',
      builder: (context, state) {
        return const UniversidadFbFormView();
      },
    ),

    // ================= EDITAR =================
    GoRoute(
      path: '/universidadesfb/edit/:id',
      name: 'universidadesfb.edit',
      builder: (context, state) {
        final String id = state.pathParameters['id']!;
        return UniversidadFbFormView(
          id: id,
        );
      },
    ),
  ],
);