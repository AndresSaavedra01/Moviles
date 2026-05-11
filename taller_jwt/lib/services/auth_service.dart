import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthService {
  final String baseUrl = dotenv.env['URL_API_REGISTRO_CLASES']!;
  //! flutter_secure_storage para guardar el token de forma segura
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  //! login se encarga de autenticar al usuario
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // 1. Apuntamos al endpoint correcto: /login (asumiendo que baseUrl termina en /api/)
      final response = await http.post(
        Uri.parse('${baseUrl}login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Prevenir el error del formato HTML si la ruta está mal
      if (response.headers['content-type']?.contains('text/html') == true) {
        return {
          'success': false,
          'message': 'Error del servidor: Ruta no encontrada (404) o error interno.',
        };
      }

      final data = jsonDecode(response.body);

      //* Manejo de respuestas exitosas (200) según la documentación
      if (response.statusCode == 200) {
        try {
          // Algunas APIs de Laravel nombran el token como 'access_token' en lugar de 'token'
          // Usamos el operador ?? para soportar ambos casos por precaución
          final String tokenStr = data['token'] ?? data['access_token'] ?? '';

          //* Guardar token de forma segura con flutter_secure_storage
          await _secureStorage.write(key: 'token', value: tokenStr);
          await _secureStorage.write(key: 'token_type', value: data['type'] ?? 'bearer');

          if (data['expires_in'] != null) {
            await _secureStorage.write(
              key: 'expires_in',
              value: data['expires_in'].toString(),
            );
          }

          //* Guardar datos del usuario con shared_preferences (no sensibles)
          // Verificamos si la API devuelve el objeto 'user' directamente
          if (data['user'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_name', data['user']['name'] ?? 'Usuario');
            await prefs.setString('user_email', data['user']['email'] ?? email);
            if (data['user']['id'] != null) {
              await prefs.setInt('user_id', data['user']['id']);
            }
            return {'success': true, 'user': User.fromJson(data['user'])};
          }

          return {'success': true};

        } catch (e) {
          debugPrint('Error al guardar credenciales: $e');
          return {
            'success': false,
            'message': 'Error al guardar credenciales localmente',
          };
        }
      }

      //* Manejo de error de autenticación (401)
      if (response.statusCode == 401) {
        return {
          'success': false,
          // Dependiendo de la API, el mensaje puede venir en 'message', 'error' o 'detail'
          'message': data['message'] ?? data['error'] ?? 'Credenciales inválidas.',
        };
      }

      //* Otro tipo de error (500, etc)
      return {
        'success': false,
        'message': data['message'] ?? 'Error desconocido al iniciar sesión. Código: ${response.statusCode}',
      };
    } catch (e) {
      debugPrint('Exception en login: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Verifica tu internet.',
      };
    }
  }

  //! getUser se encarga de obtener el usuario desde SharedPreferences
  Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('user_id');
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');

      if (id != null && name != null && email != null) {
        return User(id: id, name: name, email: email);
      }
    } catch (e) {
      debugPrint('Error al obtener usuario: $e');
    }
    return null;
  }

  //! getToken se encarga de obtener el token desde flutter_secure_storage
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'token');
    } catch (e) {
      debugPrint('Error al obtener token: $e');
      return null;
    }
  }

  //! logout elimina el token y los datos del usuario
  //! logout elimina el token en el servidor y luego los datos locales
  Future<void> logout() async {
    try {
      // 1. Obtener los headers (que incluyen el token actual)
      final headers = await getAuthHeader();

      // 2. Avisar al servidor para que invalide el JWT
      final response = await http.post(
        Uri.parse('${baseUrl}logout'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        debugPrint('Sesión cerrada correctamente en el servidor.');
      } else {
        debugPrint('El servidor respondió con código ${response.statusCode} al intentar hacer logout.');
      }
    } catch (e) {
      // Si falla la conexión, igual debemos limpiar el celular para no dejar al usuario atrapado
      debugPrint('Error de red al hacer logout en el servidor: $e');
    } finally {
      // 3. SIEMPRE limpiar los datos locales
      try {
        //* Eliminar token de flutter_secure_storage
        await _secureStorage.delete(key: 'token');
        await _secureStorage.delete(key: 'token_type');
        await _secureStorage.delete(key: 'expires_in');

        //* Eliminar datos del usuario de SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_id');
        await prefs.remove('user_name');
        await prefs.remove('user_email');
      } catch (e) {
        debugPrint('Error limpiando datos locales de logout: $e');
      }
    }
  }

  //! isLoggedIn verifica si el usuario tiene un token válido
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  //! getAuthHeader retorna el header de autenticación para las peticiones
  Future<Map<String, String>> getAuthHeader() async {
    final token = await getToken();
    final tokenType = await _secureStorage.read(key: 'token_type') ?? 'bearer';

    if (token != null) {
      return {
        'Authorization':
            '${tokenType.substring(0, 1).toUpperCase()}${tokenType.substring(1)} $token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  //! register se encarga de crear un nuevo usuario
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}users'),
        headers: {'Content-Type': 'application/json'},
        // 2. Quitamos el password_confirmation ya que el Swagger no lo pide
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      // Si el servidor devuelve un 404 o 500 en formato HTML, esto evitará el FormatException
      if (response.headers['content-type']?.contains('text/html') == true) {
        return {
          'success': false,
          'message': 'Error del servidor: Ruta no encontrada (404) o error interno.',
        };
      }

      final data = jsonDecode(response.body);

      // 3. Manejo de respuesta exitosa (el Swagger dice que devuelve 201)
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Usuario creado correctamente.',
        };
      }

      // 4. Manejo de error de validación (el Swagger dice que devuelve 422)
      if (response.statusCode == 422) {
        return {
          'success': false,
          'message': 'Error de validación. Verifica los datos.',
          // Dependiendo de cómo devuelva los errores esta API, podrías ajustar esto:
          'errorDetail': data.toString(),
        };
      }

      return {
        'success': false,
        'message': 'Error al registrar usuario. Código: ${response.statusCode}',
      };
    } catch (e) {
      debugPrint('Exception en register: $e');
      return {
        'success': false,
        'message': 'Error de conexión o formato inesperado.',
      };
    }
  }
}
