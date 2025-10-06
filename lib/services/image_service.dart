import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadImage(dynamic imageFile, String bucketPath) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileExt = kIsWeb
          ? path.extension((imageFile as XFile).name)
          : path.extension((imageFile as File).path);
      final String fullPath = '$bucketPath/$fileName$fileExt';

      Uint8List bytes;
      if (kIsWeb) {
        bytes = await imageFile.readAsBytes();
      } else {
        bytes = await imageFile.readAsBytes();
      }

      await _supabase.storage.from('productos_imagenes').uploadBinary(
            fullPath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/${fileExt.replaceAll('.', '')}',
            ),
          );

      final String downloadUrl =
          _supabase.storage.from('productos_imagenes').getPublicUrl(fullPath);

      print('Image uploaded successfully. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<dynamic> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        return pickedFile;
      } else {
        return File(pickedFile.path);
      }
    }
    return null;
  }
}
