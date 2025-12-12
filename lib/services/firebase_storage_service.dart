import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Erreur lors de la sélection de l\'image: $e');
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Erreur lors de la prise de photo: $e');
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(XFile image, {String? folder}) async {
    try {
      final String fileName = '${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = folder != null ? '$folder/$fileName' : 'anomalies/$fileName';
      
      final Reference ref = _storage.ref().child(path);
      final File file = File(image.path);
      
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image: $e');
    }
  }

  // Get upload progress stream
  Stream<double> uploadImageWithProgress(XFile image, {String? folder}) {
    final String fileName = '${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String path = folder != null ? '$folder/$fileName' : 'anomalies/$fileName';
    
    final Reference ref = _storage.ref().child(path);
    final File file = File(image.path);
    
    final UploadTask uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return uploadTask.snapshotEvents.map((event) {
      return event.bytesTransferred / event.totalBytes;
    });
  }
}

