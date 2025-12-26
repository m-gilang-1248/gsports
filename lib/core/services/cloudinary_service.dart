import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';

@lazySingleton
class CloudinaryService {
  Future<String> uploadImage(File file, {String? folder}) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null ||
        uploadPreset == null ||
        cloudName.isEmpty ||
        uploadPreset.isEmpty) {
      throw ServerException("Cloudinary configuration missing in .env");
    }

    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: false,
    );

    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw ServerException("Cloudinary Upload Failed: $e");
    }
  }

  Future<List<String>> uploadImages(List<File> files, {String? folder}) async {
    final List<String> urls = [];
    for (final file in files) {
      final url = await uploadImage(file, folder: folder);
      urls.add(url);
    }
    return urls;
  }
}
