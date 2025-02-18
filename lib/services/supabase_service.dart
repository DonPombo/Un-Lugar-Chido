import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> agregarProducto(Producto producto) async {
    try {
      await _supabase.from('productos').insert(producto.toMap());
    } catch (e) {
      print('Error al agregar producto: $e');
      throw e;
    }
  }

  Future<void> actualizarProducto(Producto producto) async {
    try {
      if (producto.id == null)
        throw Exception('ID del producto no puede ser null');
      await _supabase
          .from('productos')
          .update(producto.toMap())
          .eq('id', producto.id!);
    } catch (e) {
      print('Error al actualizar producto: $e');
      throw e;
    }
  }

  Future<void> eliminarProducto(String id) async {
    try {
      await _supabase.from('productos').delete().eq('id', id);
    } catch (e) {
      print('Error al eliminar producto: $e');
      throw e;
    }
  }

  Stream<List<Map<String, dynamic>>> getProductosStream() {
    return _supabase
        .from('productos')
        .stream(primaryKey: ['id']).map((event) => event);
  }

  Future<void> actualizarDisponibilidad(String id, bool disponible) async {
    try {
      await _supabase
          .from('productos')
          .update({'disponible': disponible}).eq('id', id);
    } catch (e) {
      print('Error al actualizar disponibilidad: $e');
      throw e;
    }
  }
}
