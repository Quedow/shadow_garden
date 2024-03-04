import 'package:flutter/material.dart';

class SortButtonIcon extends StatelessWidget {
  final int state;

  const SortButtonIcon({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late IconData icon;
    switch (state) {
      case 0:
        icon = Icons.music_note_rounded;
        break;
      case 1:
        icon = Icons.album_rounded;
        break;
      case 2:
        icon = Icons.person;
        break;
      case 3:
        icon = Icons.shuffle_rounded;
        break;
      case 4:
        icon = Icons.calendar_today_rounded;
        break;
    }
    return Icon(icon);
  }
}