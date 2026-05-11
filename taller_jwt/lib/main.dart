import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_jwt/views/auth/login_page.dart';
import 'package:taller_jwt/views/auth/register_page.dart';
import 'package:taller_jwt/views/home/home_screen.dart';

// Importaciones de tus archivos
import 'services/auth_service.dart';


void main() async {
  // 1. Asegurar que los widgets estén inicializados antes de cargar servicios
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cargar variables de entorno (.env)
  // Asegúrate de tener el archivo .env en la raíz y declarado en pubspec.yaml
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error cargando el archivo .env: $e");
  }

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

// Configuración de rutas
final GoRouter _router = GoRouter(
  initialLocation: '/',

  // Lógica de redirección para proteger rutas
  redirect: (BuildContext context, GoRouterState state) async {
    final authService = AuthService();
    final bool loggedIn = await authService.isLoggedIn();

    // Verificamos a qué pantalla intenta ir el usuario
    final bool isGoingToLogin = state.matchedLocation == '/login';
    final bool isGoingToRegister = state.matchedLocation == '/register';

    // 1. Si NO está logueado y NO va ni al login ni al registro, lo mandamos al login
    if (!loggedIn && !isGoingToLogin && !isGoingToRegister) {
      return '/login';
    }

    // 2. Si SÍ está logueado e intenta ir al login o al registro, lo mandamos al Home
    if (loggedIn && (isGoingToLogin || isGoingToRegister)) {
      return '/';
    }

    // 3. De lo contrario, dejar que continúe a donde iba
    return null;
  },

// En la configuración de rutas (dentro de routes: [...])

  routes: [
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // Aquí puedes añadir más rutas como:
    /*
    GoRoute(
      path: '/perfil',
      builder: (context, state) => const ProfileScreen(),
    ),
    */
  ],
);