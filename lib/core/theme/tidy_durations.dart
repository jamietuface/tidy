/// Animation duration tokens for Tidy.
///
/// Default curve is [Curves.easeOutCubic]. Avoid bouncing or elastic curves —
/// they break the calm.
class TidyDurations {
  const TidyDurations._();

  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration glacial = Duration(milliseconds: 600);
}
