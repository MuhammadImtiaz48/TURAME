import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static final cloudinary = Cloudinary.signedConfig(
    apiKey: '361287153134522',
    apiSecret: '1iTLiUk9zFQEeKC4CZC3SD79Bhk',
    cloudName: 'dx2np2u8j',
  );

  static Future<String?> uploadImage(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        debugPrint('CloudinaryService: File does not exist at path: $path');
        return null;
      }

      final fileBytes = await file.readAsBytes();
      final fileName = path.split('/').last;

      debugPrint('CloudinaryService: Starting upload for $fileName');

      final response = await cloudinary.upload(
        file: path,
        fileBytes: fileBytes,
        resourceType: CloudinaryResourceType.image,
        folder: 'level_plus/images',
        fileName: fileName,
        progressCallback: (count, total) {
          debugPrint('CloudinaryService: Uploading $fileName: $count/$total');
        },
      );

      if (response.isSuccessful && response.secureUrl != null) {
        debugPrint(
          'CloudinaryService: Upload successful → ${response.secureUrl}',
        );
        return response.secureUrl;
      }

      debugPrint(
        'CloudinaryService: Upload failed — isSuccessful=${response.isSuccessful}, url=${response.secureUrl}',
      );
      return null;
    } catch (e, stack) {
      debugPrint('CloudinaryService: uploadImage error → $e\n$stack');
      return null;
    }
  }

  static Future<String?> uploadImageToFolder({
    required String path,
    required List<int> fileBytes,
    required String folder,
    required String fileName,
  }) async {
    try {
      if (fileBytes.isEmpty) {
        debugPrint(
          'CloudinaryService: fileBytes is empty for fileName: $fileName',
        );
        return null;
      }

      debugPrint(
        'CloudinaryService: Uploading $fileName to folder $folder (${fileBytes.length} bytes)',
      );

      final response = await cloudinary.upload(
        file: path,
        fileBytes: fileBytes,
        resourceType: CloudinaryResourceType.image,
        folder: folder,
        fileName: fileName,
        progressCallback: (count, total) {
          debugPrint('CloudinaryService: Uploading $fileName: $count/$total');
        },
      );

      if (response.isSuccessful && response.secureUrl != null) {
        debugPrint(
          'CloudinaryService: Upload successful → ${response.secureUrl}',
        );
        return response.secureUrl;
      }

      debugPrint(
        'CloudinaryService: Upload failed for $fileName — isSuccessful=${response.isSuccessful}',
      );
      return null;
    } catch (e, stack) {
      debugPrint('CloudinaryService: uploadImageToFolder error → $e\n$stack');
      return null;
    }
  }

  static Future<List<String>> uploadMultipleImages(List<File> files) async {
    final List<String> urls = [];
    for (final file in files) {
      try {
        final url = await uploadImage(file.path);
        if (url != null) {
          urls.add(url);
        } else {
          debugPrint(
            'CloudinaryService: uploadMultipleImages — skipping failed upload for ${file.path}',
          );
        }
      } catch (e) {
        debugPrint(
          'CloudinaryService: uploadMultipleImages error for ${file.path} → $e',
        );
      }
    }
    return urls;
  }
}
