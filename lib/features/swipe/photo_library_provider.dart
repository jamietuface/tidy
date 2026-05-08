import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import 'photo_decisions_repository.dart';

enum PhotoPermission { notDetermined, authorized, limited, denied }

@immutable
class PhotoItem {
  const PhotoItem({
    required this.id,
    required this.label,
    required this.size,
    this.asset,
    this.imageUrl,
  });

  final String id;
  final String label;
  final String size;
  final AssetEntity? asset;
  final String? imageUrl;

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  static PhotoItem fromAsset(AssetEntity asset) {
    final d = asset.createDateTime;
    final label = '${_months[d.month - 1]} ${d.day}, ${d.year}';
    final size = '${asset.width} × ${asset.height}';
    return PhotoItem(id: asset.id, label: label, size: size, asset: asset);
  }
}

@immutable
class PhotoLibraryState {
  const PhotoLibraryState({
    required this.permission,
    required this.loading,
    required this.photos,
    required this.index,
    required this.kept,
    required this.deleted,
  });

  final PhotoPermission permission;
  final bool loading;
  final List<PhotoItem> photos;
  final int index;
  final List<String> kept;
  final List<String> deleted;

  bool get isDone => index >= photos.length;
  PhotoItem? get current => isDone ? null : photos[index];
  bool get isReady => !loading && permission != PhotoPermission.denied;

  static const initial = PhotoLibraryState(
    permission: PhotoPermission.notDetermined,
    loading: true,
    photos: [],
    index: 0,
    kept: [],
    deleted: [],
  );

  PhotoLibraryState copyWith({
    PhotoPermission? permission,
    bool? loading,
    List<PhotoItem>? photos,
    int? index,
    List<String>? kept,
    List<String>? deleted,
  }) =>
      PhotoLibraryState(
        permission: permission ?? this.permission,
        loading: loading ?? this.loading,
        photos: photos ?? this.photos,
        index: index ?? this.index,
        kept: kept ?? this.kept,
        deleted: deleted ?? this.deleted,
      );
}

class PhotoLibraryNotifier extends StateNotifier<PhotoLibraryState> {
  PhotoLibraryNotifier(this._decisions) : super(PhotoLibraryState.initial);

  final PhotoDecisionsRepository _decisions;

  Future<void> load() async {
    state = state.copyWith(loading: true);

    final result = await PhotoManager.requestPermissionExtend();
    final permission = _mapPermission(result);

    if (permission == PhotoPermission.denied) {
      state = state.copyWith(permission: permission, loading: false);
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      state = state.copyWith(
        permission: permission,
        loading: false,
        photos: [],
      );
      return;
    }

    final assets = await albums.first.getAssetListRange(
      start: 0,
      end: 1000,
    );

    final decidedIds = await _decisions.decidedPhotoIds();
    final remaining = assets
        .where((a) => !decidedIds.contains(a.id))
        .map(PhotoItem.fromAsset)
        .toList();

    state = state.copyWith(
      permission: permission,
      loading: false,
      photos: remaining,
    );
  }

  void keep() {
    if (state.isDone) return;
    final item = state.current!;
    state = state.copyWith(
      index: state.index + 1,
      kept: [...state.kept, item.id],
    );
    _recordWithSize(item, SwipeDecision.kept);
  }

  void delete() {
    if (state.isDone) return;
    final item = state.current!;
    state = state.copyWith(
      index: state.index + 1,
      deleted: [...state.deleted, item.id],
    );
    _recordWithSize(item, SwipeDecision.deleted);
  }

  Future<void> _recordWithSize(PhotoItem item, SwipeDecision decision) async {
    int? sizeBytes;
    try {
      final file = await item.asset?.file;
      sizeBytes = await file?.length();
    } catch (_) {
      sizeBytes = null;
    }
    await _decisions.record(
      photoId: item.id,
      decision: decision,
      photoCreatedAt: item.asset?.createDateTime,
      sizeBytes: sizeBytes,
    );
  }

  void undo() {
    if (state.index == 0) return;
    final newIndex = state.index - 1;
    final lastId = state.photos[newIndex].id;
    state = state.copyWith(
      index: newIndex,
      kept: state.kept.where((id) => id != lastId).toList(),
      deleted: state.deleted.where((id) => id != lastId).toList(),
    );
    _decisions.undo(lastId);
  }

  void openSettings() => PhotoManager.openSetting();

  static PhotoPermission _mapPermission(PermissionState result) {
    if (result.isAuth) return PhotoPermission.authorized;
    if (result.isLimited) return PhotoPermission.limited;
    return PhotoPermission.denied;
  }
}

final photoLibraryProvider =
    StateNotifierProvider<PhotoLibraryNotifier, PhotoLibraryState>(
  (ref) => PhotoLibraryNotifier(ref.watch(photoDecisionsRepositoryProvider)),
);
