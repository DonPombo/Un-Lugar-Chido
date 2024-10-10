import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadImage(dynamic imageFile, String path) async {
    try {
      final String fileName = const Uuid().v4();
      final Reference ref = _storage.ref().child('$path/$fileName');

      UploadTask uploadTask;

      // Manejo de subida de archivos dependiendo de la plataforma
      if (kIsWeb) {
        // Para web, usamos 'putData' y convertimos a bytes
        uploadTask = ref.putData(await imageFile.readAsBytes());
      } else {
        // Para móviles, aseguramos que sea un 'File'
        if (imageFile is File) {
          uploadTask = ref.putFile(imageFile);
        } else if (imageFile is XFile) {
          // Convertimos XFile a File
          uploadTask = ref.putFile(File(imageFile.path));
        } else {
          throw Exception('Unsupported file type: ${imageFile.runtimeType}');
        }
      }

      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Guardar URL en Firestore
      await _firestore.collection('images').add({
        'url': downloadUrl,
        'path': '$path/$fileName',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<dynamic> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (kIsWeb) {
        return pickedFile; // Devuelve XFile para la web
      } else {
        return File(pickedFile.path); // Convierte a File para móviles
      }
    }
    return null; // Retorna null si no se selecciona ningún archivo
  }

  Future<List<String>> getImages() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('images')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc['url'] as String).toList();
    } catch (e) {
      print('Error getting images: $e');
      return [];
    }
  }
}
