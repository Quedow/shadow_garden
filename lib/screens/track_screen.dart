import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shadow_garden/utils/audio_stream_utils.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:shadow_garden/widgets/text_display.dart';
import 'package:shadow_garden/widgets/controls.dart';
import 'package:shadow_garden/widgets/audio_progress_bar.dart';
import 'package:on_audio_query/on_audio_query.dart';

class TrackBanner extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final SequenceState? sequenceState;
  final bool isPlaying;

  const TrackBanner({Key? key, required this.audioPlayer, required this.sequenceState, required this.isPlaying}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int currentIndex = audioPlayer.currentIndex ?? 0;
    final MediaItem? currentMetadata = sequenceState?.sequence[currentIndex].tag;

    if (currentMetadata == null) { return const SizedBox.shrink(); }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          useSafeArea: true,
          context: context,
          enableDrag: true,
          builder: (BuildContext context) {
            // return StreamBuilder<SequenceState?>(
            return StreamBuilder<int?>(
              // stream: audioPlayer.sequenceStateStream,
              stream: audioPlayer.currentIndexStream,
              builder: (context, snapshot) {
                // final SequenceState? sequenceState = snapshot.data;
                // final int currentIndex = audioPlayer.currentIndex ?? 0;
                final int currentIndex = snapshot.data ?? 0;
                final MediaItem? currentMetadata = sequenceState?.sequence[currentIndex].tag;

                if (currentMetadata == null) { return const SizedBox.shrink(); }

                return getTrackPage(currentMetadata, screenWidth);
              }
            );
          }
        );
      },
      child: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white, width: 1.0))),
        // return StreamBuilder<SequenceState?>(
        child: StreamBuilder<int?>(
          // stream: audioPlayer.sequenceStateStream,
          stream: audioPlayer.currentIndexStream,
          builder: (context, snapshot) {
            // final SequenceState? sequenceState = snapshot.data;
            // final int currentIndex = audioPlayer.currentIndex ?? 0;
            final int currentIndex = snapshot.data ?? 0;
            final MediaItem? currentMetadata = sequenceState?.sequence[currentIndex].tag;

            if (currentMetadata == null) { return const SizedBox.shrink(); }
            
            return getTrackBanner(currentMetadata, screenWidth);
          }
        )
      )
    );
  }

  Container getTrackBanner(MediaItem metadata, double screenWidth) {
    const double imgWidth = 50;
    const double playBtnWidth = 50;
    final double availableWidth = screenWidth - (imgWidth - playBtnWidth)/2;

    return Container(
      width: screenWidth,
      color: ThemeColors.backgroundOled,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        leading: ClipRRect(borderRadius: BorderRadius.circular(10.0), child: QueryArtworkWidget(id: int.parse(metadata.id), type: ArtworkType.AUDIO, artworkWidth: imgWidth, artworkHeight: imgWidth, artworkFit: BoxFit.cover)),
        title: MarqueeTitle(title: metadata.title, availableWidth: availableWidth, textStyle: Styles.trackBannerTitle),
        subtitle: MarqueeSubtitle(album: metadata.album, artist: metadata.artist, availableWidth: availableWidth, textStyle: Styles.trackBannerSubtitle),
        trailing: SizedBox(width: playBtnWidth, height: playBtnWidth, child: PlayButton(audioPlayer: audioPlayer))
      )
    );
  }

  Container getTrackPage(MediaItem metadata, double screenWidth) {
    const double padding = 25;
    final double imgWidth = screenWidth - 2*padding;

    return Container(
      color: ThemeColors.backgroundOled,
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(width: imgWidth, height: imgWidth, decoration: BoxDecoration(color: ThemeColors.secondaryColor,borderRadius: BorderRadius.circular(20.0)), child: QueryArtworkWidget(id: int.parse(metadata.id), type: ArtworkType.AUDIO, artworkBorder: BorderRadius.circular(20.0), artworkWidth: imgWidth, artworkHeight: imgWidth, artworkFit: BoxFit.cover)),
          // SizedBox.square(dimension: imgWidth, child: QueryArtworkWidget(id: int.parse(metadata.id), type: ArtworkType.AUDIO, artworkBorder: BorderRadius.circular(20.0), artworkWidth: imgWidth, artworkHeight: imgWidth, artworkFit: BoxFit.cover)),
          AudioProgressBar(positionDataStream: AudioStreamUtils.getPositionDataStream(audioPlayer), audioPlayer: audioPlayer),
          MarqueeTitle(title: metadata.title, availableWidth: screenWidth, textStyle: Styles.trackPageTilte),
          MarqueeSubtitle(album: metadata.album, artist: metadata.artist, availableWidth: screenWidth, textStyle: Styles.trackPageSubtitle,),
          Controls(audioPlayer: audioPlayer)
        ]
      ),
    );
  }
}
