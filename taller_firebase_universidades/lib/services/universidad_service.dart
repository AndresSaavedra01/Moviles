
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/universidad_fb.dart';

class UniversidadService {
  // Cambiamos la colección a 'universidades'
  static final _ref = FirebaseFirestore.instance.collection('universidades');

  static Stream<UniversidadFb?> watchUniversidadById(String id) {
    return _ref.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return UniversidadFb.fromMap(doc.id, doc.data()!);
      }
      return null;
    });
  }

  /// Obtiene todas las universidades
  static Future<List<UniversidadFb>> getUniversidades() async {
    final snapshot = await _ref.get();
    return snapshot.docs
        .map((doc) => UniversidadFb.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Agrega una nueva universidad
  static Future<void> addUniversidad(UniversidadFb universidad) async {
    await _ref.add(universidad.toMap());
  }

  /// Actualiza una universidad existente
  static Future<void> updateUniversidad(UniversidadFb universidad) async {
    await _ref.doc(universidad.id).update(universidad.toMap());
  }

  /// Obtiene una universidad por su ID
  static Future<UniversidadFb?> getUniversidadById(String id) async {
    final doc = await _ref.doc(id).get();
    if (doc.exists) {
      return UniversidadFb.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  /// Elimina una universidad
  static Future<void> deleteUniversidad(String id) async {
    await _ref.doc(id).delete();
  }

  //!/ Observa los cambios en la colección
  static Stream<List<UniversidadFb>> watchUniversidades() {
    return _ref.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UniversidadFb.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}