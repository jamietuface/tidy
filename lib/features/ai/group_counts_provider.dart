import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../swipe/group_type.dart';
import 'photo_classifier.dart';

/// Hard cap on how many photos we classify in a single pass. 200 keeps
/// the worst-case wall-clock under ~10s on an iPhone 15 simulator and
/// keeps Isolate payload reasonable.
const _classifyBudget = 200;

@immutable
class GroupCounts {
  const GroupCounts({
    required this.counts,
    required this.idsByGroup,
    required this.classifiedTotal,
    required this.deviceTotal,
  });

  final Map<GroupType, int> counts;
  final Map<GroupType, Set<String>> idsByGroup;
  final int classifiedTotal;
  final int deviceTotal;

  /// Extrapolate counts proportionally if we sampled less than the full
  /// library — the AI Groups row can show an estimate.
  int scaledFor(GroupType g) {
    if (classifiedTotal == 0 || classifiedTotal >= deviceTotal) {
      return counts[g] ?? 0;
    }
    final raw = counts[g] ?? 0;
    return ((raw / classifiedTotal) * deviceTotal).round();
  }
}

/// Loads thumbnails + head bytes for up to [_classifyBudget] photos and
/// hands the batch to [classifyAll] inside an Isolate via compute().
final groupCountsProvider = FutureProvider<GroupCounts>((ref) async {
  final permission = await PhotoManager.requestPermissionExtend();
  if (!permission.hasAccess) {
    return const GroupCounts(
      counts: {},
      idsByGroup: {},
      classifiedTotal: 0,
      deviceTotal: 0,
    );
  }

  final albums = await PhotoManager.getAssetPathList(
    type: RequestType.image,
    onlyAll: true,
  );
  if (albums.isEmpty) {
    return const GroupCounts(
      counts: {},
      idsByGroup: {},
      classifiedTotal: 0,
      deviceTotal: 0,
    );
  }

  final deviceTotal = await albums.first.assetCountAsync;
  final assets = await albums.first
      .getAssetListRange(start: 0, end: _classifyBudget);

  final samples = <PhotoSample>[];
  for (final asset in assets) {
    try {
      final thumb =
          await asset.thumbnailDataWithSize(const ThumbnailSize(50, 50));
      if (thumb == null) continue;
      final file = await asset.file;
      if (file == null) continue;
      final raf = await file.open();
      final headLen = math.min(4096, await file.length());
      final head = await raf.read(headLen);
      await raf.close();
      samples.add(PhotoSample(
        id: asset.id,
        width: asset.width,
        height: asset.height,
        createdAt: asset.createDateTime,
        thumbBytes: thumb,
        headBytes: Uint8List.fromList(head),
      ));
    } catch (e) {
      dev.log('skip asset ${asset.id}: $e', name: 'group_counts');
    }
  }

  final results = await compute(classifyAll, samples);
  return GroupCounts(
    counts: results.counts,
    idsByGroup: results.byGroup,
    classifiedTotal: samples.length,
    deviceTotal: deviceTotal,
  );
});

/// Load AssetEntity instances for a specific group's classified IDs,
/// so the GroupSwipeScreen can swipe through the actual photos.
final groupAssetsProvider =
    FutureProvider.family<List<AssetEntity>, GroupType>((ref, group) async {
  final counts = await ref.watch(groupCountsProvider.future);
  final ids = counts.idsByGroup[group] ?? const <String>{};
  if (ids.isEmpty) return const [];
  final assets = <AssetEntity>[];
  for (final id in ids) {
    final asset = await AssetEntity.fromId(id);
    if (asset != null) assets.add(asset);
  }
  return assets;
});

