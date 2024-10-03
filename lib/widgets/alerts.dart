import 'package:flutter/material.dart';
import 'package:shadow_garden/style/common_text.dart';
import 'package:shadow_garden/style/style.dart';

abstract class Alerts {
  static Future<void> deletionDialog(BuildContext context, void Function() onConfirmation) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceAround,
          title: Text(Texts.textDeletionDialog, style: Styles.titleLarge.copyWith(color: Colors.white)),
          backgroundColor: ThemeColors.surfaceColor,
          actions: [
            IconButton(icon: const Icon(Icons.cancel_rounded, color: ThemeColors.errorColor),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            IconButton(icon: const Icon(Icons.check_circle_rounded, color: ThemeColors.accentColor),
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