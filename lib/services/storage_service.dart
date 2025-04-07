import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file to Firebase Storage
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  // Delete a file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      if (fileUrl.startsWith('https://firebasestorage.googleapis.com')) {
        final ref = _storage.refFromURL(fileUrl);
        await ref.delete();
      }
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }
}
