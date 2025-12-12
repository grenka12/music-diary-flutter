import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  StorageRepository._();

  static Future<String> uploadCoverImage(String userId, File file) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'images/$userId/$timestamp.jpg';
    final storageRef = FirebaseStorage.instance.ref().child(storagePath);

    await storageRef.putFile(file);
    return storageRef.getDownloadURL();
  }
}
