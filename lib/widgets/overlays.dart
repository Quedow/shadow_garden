import 'package:flutter/material.dart';
import 'package:shadow_garden/utils/translator.dart';

class Dialogs {
  static Future<void> deletionDialog(BuildContext context, void Function() onConfirmation) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceAround,
          title: Text('textDeletionDialog'.t(), style: Theme.of(context).textTheme.headlineSmall),
          actions: [
            IconButton(icon: Icon(Icons.cancel_rounded, color: Theme.of(context).colorScheme.error),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(icon: Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary),
              onPressed: () {
                onConfirmation();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> deletionDialogAdvanced(BuildContext context, { required List<Map<Widget, void Function()?>> actions, String? title }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceAround,
          actionsOverflowAlignment: OverflowBarAlignment.start,
          title: Text('textDeletionDialog'.t(), style: Theme.of(context).textTheme.headlineSmall),
          actions: actions.map<Widget>((action) {
            final Widget button = action.keys.first;
            final void Function()? onConfirmation = action.values.first;
            return TextButton(
              child: button,
              onPressed: () {
                onConfirmation?.call();
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class Snack {
  static SnackBar floating(BuildContext context, String content, int duration){
    return SnackBar(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content, maxLines: 1, style: Theme.of(context).textTheme.labelMedium, overflow: TextOverflow.ellipsis),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      duration: Duration(milliseconds: duration),
    );
  }
}