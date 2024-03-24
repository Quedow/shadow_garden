import 'package:flutter/material.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/style.dart';

class SettingsScreen extends StatefulWidget {
  final AudioProvider audioProvider;

  const SettingsScreen({Key? key, required this.audioProvider}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Save data", style: Styles.settingsTitle),
                  Text("Listening data will be saved to improve\nsmart sort (data still local).", style: Styles.settingsDescription)
                ],
              ),
              IconButton(onPressed: widget.audioProvider.saveInDatabase, icon: const Icon(Icons.save_alt_rounded, color: ThemeColors.primaryColor)),
            ]
          ),
        ),
        Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor.withOpacity(0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Delete data", style: Styles.settingsTitle),
                  Text("Listening data will be delete to reset\nsmart sort.", style: Styles.settingsDescription)
                ],
              ),
              IconButton(onPressed: widget.audioProvider.clearDatabase, icon: const Icon(Icons.delete_rounded, color: ThemeColors.primaryColor)),
            ]
          ),
        )
      ],
    );
  }
}