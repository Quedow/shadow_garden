import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class SongArtwork extends StatelessWidget {
  final int songId;
  final double imgWidth;

  const SongArtwork({super.key, required this.songId, required this.imgWidth});

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: songId,
      keepOldArtwork: true,
      type: ArtworkType.AUDIO,
      artworkFit: BoxFit.cover,
      artworkWidth: imgWidth,
      artworkHeight: imgWidth,
      artworkQuality: FilterQuality.low,
      artworkBorder: BorderRadius.circular(10.0),
      nullArtworkWidget: BlankArtwork(imgWidth: imgWidth),
    );
  }
}

class BlankArtwork extends StatelessWidget {
  final double imgWidth;

  const BlankArtwork({super.key, required this.imgWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: imgWidth,
      height: imgWidth,
      decoration: BoxDecoration(color: Theme.of(context).dialogTheme.backgroundColor, borderRadius: BorderRadius.circular(10.0)),
      child: Icon(Icons.music_note_rounded, color: Theme.of(context).colorScheme.primary, size: imgWidth/2),
    );
  }
}

class ErrorArtwork extends StatelessWidget {
  final double imgWidth;

  const ErrorArtwork({super.key, required this.imgWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: imgWidth,
      height: imgWidth,
      decoration: BoxDecoration(color: Theme.of(context).dialogTheme.backgroundColor, borderRadius: BorderRadius.circular(10.0)),
      child: Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error, size: imgWidth/2),
    );
  }
}
