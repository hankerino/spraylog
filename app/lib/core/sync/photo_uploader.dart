import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../providers.dart';

/// Best-effort photo upload to the private `application-photos` bucket,
/// with one `application_photos` row per file (RLS scopes it per company).
///
/// A failed photo never blocks the record: per-file errors are collected
/// and skipped, and the caller gets the count that made it. Files stay on
/// device either way.
///
/// NOTE(follow-up): offline photo sync via the outbox is not wired yet —
/// uploads happen only when online at sign time.
class PhotoUploader {
  const PhotoUploader(this._supabase);

  final SupabaseClient _supabase;

  static const _bucket = 'application-photos';

  /// Uploads every file in [filePaths] to
  /// `<companyId>/<applicationId>/<uuid>.jpg` and inserts the matching
  /// `application_photos` row. Returns the number successfully uploaded.
  Future<int> upload({
    required String companyId,
    required String applicationId,
    required List<String> filePaths,
    double? lat,
    double? lng,
  }) async {
    var uploaded = 0;
    for (final filePath in filePaths) {
      try {
        final bytes = await File(filePath).readAsBytes();
        final storagePath =
            '$companyId/$applicationId/${const Uuid().v4()}.jpg';
        await _supabase.storage.from(_bucket).uploadBinary(
              storagePath,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );
        await _supabase.from('application_photos').insert({
          'company_id': companyId,
          'application_id': applicationId,
          'storage_path': storagePath,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          'taken_at': DateTime.now().toUtc().toIso8601String(),
        });
        uploaded++;
      } catch (_) {
        // Best-effort: skip this file, keep going.
      }
    }
    return uploaded;
  }
}

final photoUploaderProvider = Provider<PhotoUploader>(
  (ref) => PhotoUploader(ref.watch(supabaseClientProvider)),
);
