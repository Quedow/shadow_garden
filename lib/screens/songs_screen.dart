import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shadow_garden/screens/song_banner.dart';
import 'package:shadow_garden/style/common_text.dart';
import 'package:shadow_garden/widgets/text_display.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:shadow_garden/utils/functions.dart';
import 'package:shadow_garden/widgets/playing_animation.dart';

class SongsScreen extends StatefulWidget {
  final AudioProvider audioProvider;
  final bool isPlaying;

  const SongsScreen({super.key, required this.audioProvider, required this.isPlaying});

  @override
  SongsScreenState createState() => SongsScreenState();
}

class SongsScreenState extends State<SongsScreen> {
  AudioPlayer get _audioPlayer => widget.audioProvider.audioPlayer;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<int> songIndexes = [];
  int currentIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double scrollbarThickness = 10.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: TextField(
            onChanged: (value) => searchFor(value),
            onSubmitted: (value) => nextResult(),
            focusNode: _focusNode,
            decoration: InputDecoration(
              icon: Icon(Icons.search_rounded, color: Theme.of(context).hintColor),
              hintText: 'Search',
              hintStyle: Styles.hintText,
              border: InputBorder.none,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<SequenceState?>(
            stream: _audioPlayer.sequenceStateStream,
            builder: (context, snapshot) {
              final SequenceState? state = snapshot.data;
              
              if (state == null || state.sequence.isEmpty) {
                return Center(child: Text(Texts.errorNoSongFound, style: Theme.of(context).textTheme.headlineSmall));
              } else {
                final int playlistLength = state.sequence.length;

                return Scrollbar(
                  controller: _scrollController,
                  thickness: scrollbarThickness,
                  thumbVisibility: true,
                  radius: const Radius.circular(20),
                  interactive: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(right: scrollbarThickness),
                    itemCount: playlistLength,
                    itemBuilder: (context, index) {
                      final MediaItem metadata = state.sequence[index].tag;
                      final bool isCurrentSong = _audioPlayer.currentIndex == index;
                      
                      return ListTile(
                        onTap: () => Functions.onTap(_audioPlayer, widget.isPlaying, isCurrentSong, index),
                        onLongPress: () => Functions.onLongPress(widget.audioProvider, _audioPlayer, context, index),
                        leading: Artworks.artworkStyle(context, int.parse(metadata.id), Artworks.artworkSmallSize),
                        title: TitleText(title: '${index + 1} - ${metadata.title}', textStyle: Styles.songHomeTitle(context, isCurrentSong)),
                        subtitle: SubtitleText(album: metadata.album, artist: metadata.artist, textStyle: Theme.of(context).textTheme.labelLarge!),
                        trailing: PlayingAnimation(isCurrentSong: isCurrentSong, isPlaying: widget.isPlaying),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
        SongBanner(audioPlayer: _audioPlayer, isPlaying: widget.isPlaying),
      ],
    );
  }

  void searchFor(String query) {    
    if (query.isEmpty) { 
      songIndexes.clear();
    } else {
      String lowerCaseQuery = query.toLowerCase();
      songIndexes = widget.audioProvider.songs.asMap().entries.where(
        (entry) {
          SongModel song = entry.value;
          return (song.title.toLowerCase().contains(lowerCaseQuery)) ||
            (song.album != null && song.album!.toLowerCase().contains(lowerCaseQuery)) ||
            (song.artist != null && song.artist!.toLowerCase().contains(lowerCaseQuery));
        },
      ).map((entry) => entry.key).toList();

      if (songIndexes.isNotEmpty) {
        currentIndex = 0;
        scrollToIndex(songIndexes[currentIndex]);
      }
    }
  }

  void nextResult() {
    if (songIndexes.isNotEmpty) {
      currentIndex = (currentIndex + 1) % songIndexes.length;
      scrollToIndex(songIndexes[currentIndex]);
      _focusNode.requestFocus();
    }
  }

  void scrollToIndex(int index) {
    double targetPosition = min(72.0 * index, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }
}