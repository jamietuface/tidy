import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoDeletionService {
  /// Deletes the supplied asset IDs from the iOS Photos library. iOS shows
  /// ONE native confirmation dialog covering the whole batch.
  /// Returns the list of IDs that were actually deleted (may be empty if
  /// the user cancelled the system dialog).
  Future<List<String>> deleteFromLibrary(List<String> assetIds) async {
    if (assetIds.isEmpty) return const [];
    try {
      final deleted = await PhotoManager.editor.deleteWithIds(assetIds);
      return deleted;
    } catch (e) {
      dev.log('deleteWithIds failed: $e', name: 'photo_deletion');
      return const [];
    }
  }
}

final photoDeletionServiceProvider = Provider<PhotoDeletionService>(
  (ref) => PhotoDeletionService(),
);
