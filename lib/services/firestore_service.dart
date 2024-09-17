import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Producto>> getProductos() async {
    QuerySnapshot snapshot = await _firestore.collection('productos').get();
    return snapshot.docs.map((doc) => Producto.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<void> agregarProducto(Producto producto) async {
    await _firestore.collection('productos').add(producto.toMap());
  }

  Future<void> actualizarProducto(Producto producto) async {
    await _firestore.collection('productos').doc(producto.id).update(producto.toMap());
  }

  Future<void> actualizarDisponibilidad(String productoId, bool disponible) async {
    await _firestore.collection('productos').doc(productoId).update({'disponible': disponible});
  }
}