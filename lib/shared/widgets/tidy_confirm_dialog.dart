import 'package:flutter/cupertino.dart';

/// Show a Tidy-styled confirmation dialog with cancel + destructive actions.
/// Returns `true` if the user confirmed, `false` (or `null`) if cancelled.
///
/// Uses CupertinoAlertDialog because Tidy is iOS-first; on Android it still
/// renders a recognisable iOS-flavoured sheet via the Cupertino library.
/// Reserved for hard-destructive flows (sign out, delete account, delete
/// all photos) — soft-destructive flows should use a snackbar+undo.
Future<bool?> showTidyConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = true,
}) {
  return showCupertinoDialog<bool>(
    context: context,
    builder: (ctx) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
}
