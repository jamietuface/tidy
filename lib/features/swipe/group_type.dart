import 'package:flutter/cupertino.dart';

import '../../theme/app_theme.dart';

enum GroupType {
  blurry,
  screenshots,
  duplicates,
  old;

  String get title => switch (this) {
        GroupType.blurry => 'Blurry Photos',
        GroupType.screenshots => 'Screenshots',
        GroupType.duplicates => 'Duplicates',
        GroupType.old => 'Old Photos',
      };

  String get shortLabel => switch (this) {
        GroupType.blurry => 'Blurry',
        GroupType.screenshots => 'Screenshots',
        GroupType.duplicates => 'Duplicates',
        GroupType.old => 'Old',
      };

  IconData get icon => switch (this) {
        GroupType.blurry => CupertinoIcons.rays,
        GroupType.screenshots => CupertinoIcons.device_phone_portrait,
        GroupType.duplicates => CupertinoIcons.square_on_square,
        GroupType.old => CupertinoIcons.clock,
      };

  Color get color => switch (this) {
        GroupType.blurry => AppColors.systemOrange,
        GroupType.screenshots => AppColors.systemBlue,
        GroupType.duplicates => AppColors.systemPurple,
        GroupType.old => AppColors.systemGray,
      };
}
