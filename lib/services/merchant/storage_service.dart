import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fungsi untuk mengekstrak path dari URL Supabase Storage
  String? extractPathFromUrl(String publicUrl, String bucketName) {
    try {
      final uri = Uri.parse(publicUrl);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(bucketName);

      if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
        return segments.sublist(bucketIndex + 1).join('/');
      }
      print(
        'Supabase Storage: Could not extract path from URL. Bucket not found or path is empty.',
      );
      return null;
    } catch (e) {
      print('Supabase Storage: Error parsing URL to extract path: $e');
      return null;
    }
  }

  Future<String?> uploadImage({
    required File imageFile,
    required String bucketName,
    required String path,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';
      final String fullPath = '$path/$fileName';

      await _supabase.storage
          .from(bucketName)
          .upload(
            fullPath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      final imageUrlResponse = _supabase.storage
          .from(bucketName)
          .getPublicUrl(fullPath);
      return imageUrlResponse;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      return null;
    }
  }

  Future<bool> deleteImage({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      print(
        'Supabase Storage: Attempting to delete from bucket "$bucketName" at path "$filePath"',
      );
      final List<FileObject> result = await _supabase.storage
          .from(bucketName)
          .remove([filePath]);
      if (result.isNotEmpty) {
        print('Supabase Storage: Successfully deleted $filePath');
        return true;
      } else {
        print(
          'Supabase Storage: Failed to delete $filePath or file not found (no exception). Result: $result',
        );
        return false;
      }
    } on StorageException catch (e) {
      print('Supabase StorageException during delete: ${e.message}');
      print('Supabase StorageException details: ${e.statusCode} - ${e.error}');
      return false;
    } catch (e, s) {
      print('Error deleting image from Supabase: $e');
      print('Stack trace: $s');
      return false;
    }
  }
}
