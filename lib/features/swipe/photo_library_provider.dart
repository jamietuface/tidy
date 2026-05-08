import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class PhotoItem {
  const PhotoItem({
    required this.id,
    required this.imageUrl,
    required this.label,
    required this.size,
  });

  final String id;
  final String imageUrl;
  final String label;
  final String size;
}

@immutable
class PhotoLibraryState {
  const PhotoLibraryState({
    required this.photos,
    required this.index,
    required this.kept,
    required this.deleted,
  });

  final List<PhotoItem> photos;
  final int index;
  final List<String> kept;
  final List<String> deleted;

  bool get isDone => index >= photos.length;
  PhotoItem? get current => isDone ? null : photos[index];

  PhotoLibraryState copyWith({
    int? index,
    List<String>? kept,
    List<String>? deleted,
  }) =>
      PhotoLibraryState(
        photos: photos,
        index: index ?? this.index,
        kept: kept ?? this.kept,
        deleted: deleted ?? this.deleted,
      );
}

class PhotoLibraryNotifier extends StateNotifier<PhotoLibraryState> {
  PhotoLibraryNotifier()
      : super(PhotoLibraryState(
          photos: _mock(),
          index: 0,
          kept: const [],
          deleted: const [],
        ));

  void keep() {
    if (state.isDone) return;
    final id = state.current!.id;
    debugPrint('[PhotoLibrary] keep: $id');
    state = state.copyWith(
      index: state.index + 1,
      kept: [...state.kept, id],
    );
  }

  void delete() {
    if (state.isDone) return;
    final id = state.current!.id;
    debugPrint('[PhotoLibrary] delete: $id');
    state = state.copyWith(
      index: state.index + 1,
      deleted: [...state.deleted, id],
    );
  }

  void undo() {
    if (state.index == 0) return;
    final newIndex = state.index - 1;
    final lastPhotoId = state.photos[newIndex].id;
    debugPrint('[PhotoLibrary] undo: $lastPhotoId');
    state = state.copyWith(
      index: newIndex,
      kept: state.kept.where((id) => id != lastPhotoId).toList(),
      deleted: state.deleted.where((id) => id != lastPhotoId).toList(),
    );
  }

  static List<PhotoItem> _mock() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final sizes = [3.2, 1.1, 4.6, 2.8, 5.1, 3.7, 2.0, 0.8, 4.2, 6.5, 3.0, 1.9];
    return List.generate(847, (i) {
      final d = now.subtract(Duration(days: i));
      return PhotoItem(
        id: 'mock_$i',
        imageUrl: 'https://picsum.photos/seed/tidy_$i/600/800',
        label: '${months[d.month - 1]} ${d.day}, ${d.year}',
        size: '${sizes[i % sizes.length].toStringAsFixed(1)} MB',
      );
    });
  }
}

final photoLibraryProvider =
    StateNotifierProvider<PhotoLibraryNotifier, PhotoLibraryState>(
  (ref) => PhotoLibraryNotifier(),
);
