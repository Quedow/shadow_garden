import 'package:flutter/material.dart';
import 'package:shadow_garden/style/common_text.dart';

abstract class Alerts {
  static Future<void> deletionDialog(BuildContext context, void Function() onConfirmation) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceAround,
          title: Text(Texts.textDeletionDialog, style: Theme.of(context).textTheme.headlineSmall),
          actions: [
            IconButton(icon: Icon(Icons.cancel_rounded, color: Theme.of(context).colorScheme.error),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            IconButton(icon: Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary),
              onPressed: () async {
                onConfirmation();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}