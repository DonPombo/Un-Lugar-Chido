import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 
  Future<void> agregarProducto(Producto producto, [imageFile]) async {
    await _firestore.collection('productos').add(producto.toMap());
  }

  Future<void> actualizarProducto(Producto producto, [imageFile]) async {
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
