import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image/image.dart' as img;

class CloudinaryStorageService {
  final cloudinary = CloudinaryPublic(
    'dizq07zqn',
    'profile_unsigned', // default, override in method if needed
    cache: false,
  );

  // Helper: Compress image as JPEG with specified quality
  Future<File> compressImage(File file, {int quality = 80}) async {
    // Read image data
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception("Could not decode Image.");

    // Compress
    final compressed = img.encodeJpg(image, quality: quality);

    // Save to temp file
    final tempDir = Directory.systemTemp;
    final tempFile =
        await File(
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
        ).create();
    await tempFile.writeAsBytes(compressed);

    return tempFile;
  }

  Future<String> uploadProfilePic(File file, String username) async {
    // Compress before upload
    final compressedFile = await compressImage(file, quality: 80);

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        compressedFile.path,
        resourceType: CloudinaryResourceType.Image,
        folder: 'profile_pics',
        publicId: username,
      ),
      uploadPreset: 'profile_unsigned',
    );

    return response.secureUrl;
  }

  Future<String> uploadCoverPic(File file, String username) async {
    // Compress before upload
    final compressedFile = await compressImage(file, quality: 70); // More aggressive for cover

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        compressedFile.path,
        resourceType: CloudinaryResourceType.Image,
        folder: "cover_pics",
        publicId: username,
      ),
      uploadPreset: 'cover_unsigned',    // Your upload preset for cover pics
    );
    return response.secureUrl;
  }
}
