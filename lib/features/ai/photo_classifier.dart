import 'dart:math' as math;

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../swipe/group_type.dart';

/// Heuristic on-device classifiers for photo groups. No ML model.
/// All entry points are pure functions — safe to call inside compute().

/// Variance-of-Laplacian threshold below which a photo is considered blurry.
/// Calibrated for 50×50 thumbnails sampled from typical phone photos.
const _blurThreshold = 80.0;

/// Photo created [olderThanYears] years ago counts as Old.
const _olderThanYears = 2;

/// Common iOS screen pixel resolutions (portrait). If the image dimensions
/// match these exactly, we treat it as a screenshot. We also fall back to
/// aspect ratio heuristics for foreign devices.
const _screenshotExactSizes = <_Size>[
  _Size(1170, 2532), // iPhone 12/13/14
  _Size(1179, 2556), // iPhone 14 Pro/15
  _Size(1290, 2796), // iPhone 14 Pro Max/15 Pro Max
  _Size(1284, 2778), // iPhone 12 Pro Max
  _Size(828, 1792),  // iPhone 11/XR
  _Size(1125, 2436), // iPhone X/XS/11 Pro
  _Size(750, 1334),  // iPhone SE 2/3, 8
  _Size(1080, 1920), // generic Android FHD
  _Size(1440, 3120), // Pixel
  _Size(390, 844),   // logical points (rare but cheap to check)
];

class _Size {
  const _Size(this.w, this.h);
  final int w;
  final int h;
}

@immutable
class PhotoSample {
  const PhotoSample({
    required this.id,
    required this.width,
    required this.height,
    required this.createdAt,
    required this.thumbBytes,
    required this.headBytes,
  });

  final String id;
  final int width;
  final int height;
  final DateTime createdAt;

  /// 50×50 (or similar) decoded thumbnail used for blur detection.
  final Uint8List thumbBytes;

  /// First ~4 KB of the original file used for content hashing.
  final Uint8List headBytes;
}

@immutable
class GroupResults {
  const GroupResults(this.byGroup);
  final Map<GroupType, Set<String>> byGroup;

  Map<GroupType, int> get counts =>
      byGroup.map((k, v) => MapEntry(k, v.length));
}

/// Pure top-level function so it can run inside compute() / Isolate.
GroupResults classifyAll(List<PhotoSample> samples) {
  final blurry = <String>{};
  final screenshots = <String>{};
  final old = <String>{};
  final duplicates = <String>{};

  // Bucket by content hash to find duplicates (≥ 2 photos sharing a hash).
  final byHash = <String, List<String>>{};
  final cutoff = DateTime.now().subtract(const Duration(days: 365 * _olderThanYears));

  for (final s in samples) {
    if (_isBlurry(s.thumbBytes)) blurry.add(s.id);
    if (_isScreenshot(s.width, s.height)) screenshots.add(s.id);
    if (s.createdAt.isBefore(cutoff)) old.add(s.id);

    final hash = crypto.md5.convert(s.headBytes).toString();
    byHash.putIfAbsent(hash, () => <String>[]).add(s.id);
  }

  for (final ids in byHash.values) {
    if (ids.length >= 2) duplicates.addAll(ids);
  }

  return GroupResults({
    GroupType.blurry: blurry,
    GroupType.screenshots: screenshots,
    GroupType.duplicates: duplicates,
    GroupType.old: old,
  });
}

/// Variance of the Laplacian over a 50×50 sample. Low variance = low edge
/// energy = blurry image.
bool _isBlurry(Uint8List thumbBytes) {
  final decoded = img.decodeImage(thumbBytes);
  if (decoded == null) return false;
  final gray = img.grayscale(img.copyResize(decoded, width: 50, height: 50));

  // Compute |center − neighbour| differences in a 4-neighbourhood and take
  // their variance (cheap proxy for variance-of-Laplacian).
  final values = <double>[];
  for (var y = 1; y < gray.height - 1; y++) {
    for (var x = 1; x < gray.width - 1; x++) {
      final c = gray.getPixel(x, y).luminance;
      final n = gray.getPixel(x, y - 1).luminance;
      final s = gray.getPixel(x, y + 1).luminance;
      final w = gray.getPixel(x - 1, y).luminance;
      final e = gray.getPixel(x + 1, y).luminance;
      final lap = (4 * c) - n - s - w - e;
      values.add(lap.toDouble());
    }
  }
  if (values.isEmpty) return false;
  final mean = values.reduce((a, b) => a + b) / values.length;
  final variance = values
          .map((v) => (v - mean) * (v - mean))
          .reduce((a, b) => a + b) /
      values.length;
  return variance < _blurThreshold;
}

bool _isScreenshot(int width, int height) {
  // Exact resolution match (portrait or landscape).
  for (final s in _screenshotExactSizes) {
    if ((width == s.w && height == s.h) ||
        (width == s.h && height == s.w)) {
      return true;
    }
  }
  // Aspect-ratio heuristic — allow common phone ratios within 1%.
  final ratio = math.max(width, height) / math.min(width, height);
  const candidates = [
    16 / 9,
    19.5 / 9,
    20 / 9,
    18 / 9,
  ];
  for (final c in candidates) {
    if ((ratio - c).abs() / c < 0.01) return true;
  }
  return false;
}
