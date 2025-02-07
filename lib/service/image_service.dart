import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = const Uuid();

  Future<String> uploadRecipeImage(File imageFile) async {
    try {
      // Generate a unique filename
      String fileName = '${uuid.v4()}${path.extension(imageFile.path)}';
      
      // Compress the image
      final compressedImage = await compressImage(imageFile);
      if (compressedImage == null) {
        throw 'Failed to compress image';
      }

      // Create storage reference
      final storageRef = _storage.ref().child('recipe_images/$fileName');

      // Upload compressed image
      final uploadTask = await storageRef.putFile(
        compressedImage,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': imageFile.path},
        ),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      // Delete the temporary compressed file
      await compressedImage.delete();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  Future<String> convertImageToBase64(File imageFile) async {
    try {
      // Compress the image first
      final compressedImage = await compressImage(imageFile);
      if (compressedImage == null) {
        throw 'Failed to compress image';
      }

      // Read the compressed image as bytes
      final bytes = await compressedImage.readAsBytes();
      
      // Convert to base64
      String base64Image = base64Encode(bytes);
      
      // Delete the temporary compressed file
      await compressedImage.delete();

      return base64Image;
    } catch (e) {
      throw 'Failed to convert image: $e';
    }
  }

  Future<File?> compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
      final splitted = filePath.substring(0, lastIndex);
      final outPath = "${splitted}_compressed.jpg";
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 70,  // Adjust quality to ensure size is under 1MB
        format: CompressFormat.jpeg,
      );

      return compressedFile != null ? File(compressedFile.path) : null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete image: $e';
    }
  }
}