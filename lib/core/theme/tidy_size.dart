/// Size tokens for Tidy components — used where TidySpacing isn't
/// semantically right (e.g., a component height, not a gap between siblings).
class TidySize {
  const TidySize._();

  /// Bottom navigation bar height. Snackbars + bottom-anchored CTAs
  /// reference this to compute clear margins above the bar.
  static const double navBarHeight = 64;
}
