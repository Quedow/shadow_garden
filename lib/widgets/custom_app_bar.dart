import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadow_garden/pages/settings_page.dart';
import 'package:shadow_garden/providers/audio_provider.dart';
import 'package:shadow_garden/widgets/controls.dart';

enum AppBarType {
  home,
  classic,
  setting,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarType appBarType;
  final String title;
  final AudioProvider audioProvider;

  const CustomAppBar({super.key, required this.appBarType, required this.title, required this.audioProvider});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    switch (appBarType) {
      case AppBarType.home:
        return Consumer<AudioProvider>(
          builder: (context, audioProvider, child) {
            return AppBar(
              title: Text(title),
              actions: [
                IconButton(onPressed: audioProvider.setShuffleActive, icon: Icon(Icons.shuffle_rounded, color: audioProvider.shuffleActive ? themeData.colorScheme.primary : themeData.colorScheme.secondary)),
                IconButton(onPressed: audioProvider.setSortState, icon: SortButtonIcon(state: audioProvider.sortState), color: audioProvider.shuffleActive ? themeData.colorScheme.secondary : themeData.colorScheme.primary),
              ],
            );
          },
        );
      case AppBarType.setting:
        return AppBar(
          title: Text(title),
          actions: [
            IconButton(onPressed: () => _openSettings(context, audioProvider), icon: Icon(Icons.settings, color: themeData.colorScheme.secondary)),
          ],
        );
      default:
        return AppBar(title: Text(title));
    }
  }

  void _openSettings(BuildContext context, AudioProvider audioProvider) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(audioProvider: audioProvider)));
  }
}