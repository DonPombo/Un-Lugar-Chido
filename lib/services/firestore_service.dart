import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Importa Firebase Storage
import '../models/producto.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Subir imagen a Firebase Storage (móvil o web)
  Future<String> subirImagen(dynamic image,
      {bool isWeb = false, required String fileName}) async {
    String filePath = 'productos/$fileName';

    Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
    UploadTask uploadTask;

    try {
      if (isWeb) {
        uploadTask = storageRef.putData(image as Uint8List); // Para web
      } else {
        uploadTask = storageRef.putFile(image as File); // Para móviles
      }

      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir la imagen: $e');
      throw e;
    }
  }

  Future<List<Producto>> getProductos() async {
    QuerySnapshot snapshot = await _firestore.collection('productos').get();
    return snapshot.docs
        .map((doc) =>
            Producto.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> agregarProducto(Producto producto) async {
    await _firestore.collection('productos').add(producto.toMap());
  }

  Future<void> actualizarProducto(Producto producto) async {
    await _firestore
        .collection('productos')
        .doc(producto.id)
        .update(producto.toMap());
  }

  Future<void> actualizarDisponibilidad(
      String productoId, bool disponible) async {
    await _firestore
        .collection('productos')
        .doc(productoId)
        .update({'disponible': disponible});
  }

  Future<void> eliminarProducto(String productoId) async {
    await _firestore.collection('productos').doc(productoId).delete();
  }

  Stream<QuerySnapshot> getProductosStream() {
    return _firestore.collection('productos').snapshots();
  }
}
