import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shadow_garden/utils/translator.dart';
import 'package:shadow_garden/widgets/artworks.dart';
import 'package:shadow_garden/widgets/text_display.dart';
import 'package:shadow_garden/providers/audio_provider.dart';
import 'package:shadow_garden/utils/styles.dart';
import 'package:shadow_garden/utils/utility.dart';
import 'package:shadow_garden/widgets/playing_animation.dart';

class SongsScreen extends StatefulWidget {
  final AudioProvider audioProvider;

  const SongsScreen({super.key, required this.audioProvider});

  @override
  SongsScreenState createState() => SongsScreenState();
}

class SongsScreenState extends State<SongsScreen> {
  AudioProvider get _audioProvider => widget.audioProvider;
  AudioPlayer get _audioPlayer => widget.audioProvider.audioPlayer;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<int> _songIndexes = [];
  int _currentIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 20, right: 10),
          leading: Icon(Icons.search_rounded, color: Theme.of(context).hintColor),
          title: TextField(
            onChanged: (value) => searchFor(value),
            onSubmitted: (value) => nextResult(),
            focusNode: _focusNode,
            decoration: InputDecoration(
              isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none,
              hintText: 'searchLabel'.t(), hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.my_location_rounded, color: Theme.of(context).hintColor),
            onPressed: () => scrollToIndex(_audioPlayer.currentIndex ?? 0),
          ),
        ),
        Expanded(
          child: StreamBuilder<SequenceState?>(
            stream: _audioPlayer.sequenceStateStream,
            builder: (context, snapshot) {
              final SequenceState? state = snapshot.data;
              
              if (state == null || state.sequence.isEmpty) {
                return Center(child: Text('errorNoSongFound'.t(), style: Theme.of(context).textTheme.headlineSmall));
              } else {
                final int playlistLength = state.sequence.length;

                return Scrollbar(
                  controller: _scrollController,
                  thickness: DesignSystem.scrollbarThickness,
                  thumbVisibility: true,
                  radius: const Radius.circular(20),
                  interactive: true,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: ListView.builder(
                      key: ValueKey(_audioProvider.sortState),
                      controller: _scrollController,
                      padding: const EdgeInsets.only(right: DesignSystem.scrollbarThickness),
                      itemCount: playlistLength,
                      itemBuilder: (context, index) {
                        final MediaItem metadata = state.sequence[index].tag;
                        final bool isCurrentSong = _audioPlayer.currentIndex == index;
                        
                        return ListTile(
                          onTap: () => Utility.onTap(_audioProvider, _audioPlayer, isCurrentSong, index),
                          onLongPress: () => Utility.onLongPress(_audioPlayer, context, index),
                          leading: SongArtwork(songId: int.parse(metadata.id), imgWidth: DesignSystem.artworkSmallSize),
                          title: TitleText(title: metadata.title, textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(color: isCurrentSong ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary)),
                          subtitle: SubtitleText(album: metadata.album, artist: metadata.artist, textStyle: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.tertiary)),
                          trailing: PlayingAnimation(audioPlayer: _audioPlayer, isCurrentSong: isCurrentSong),
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void searchFor(String query) {
    if (query.isEmpty) {
      _songIndexes.clear();
    } else {
      String lowerCaseQuery = query.toLowerCase();
      _songIndexes = _audioPlayer.sequence.asMap().entries.where(
        (entry) {
          final MediaItem tag = entry.value.tag;
          return (tag.title.toLowerCase().contains(lowerCaseQuery)) ||
            (tag.album != null && tag.album!.toLowerCase().contains(lowerCaseQuery)) ||
            (tag.artist != null && tag.artist!.toLowerCase().contains(lowerCaseQuery));
        },
      ).map((entry) => entry.key).toList();

      if (_songIndexes.isNotEmpty) {
        _currentIndex = 0;
        scrollToIndex(_songIndexes[_currentIndex]);
      }
    }
  }

  void nextResult() {
    if (_songIndexes.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % _songIndexes.length;
      scrollToIndex(_songIndexes[_currentIndex]);
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