import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shadow_garden/utils/audio_stream_utils.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:shadow_garden/widgets/text_display.dart';
import 'package:shadow_garden/widgets/controls.dart';
import 'package:shadow_garden/widgets/audio_progress_bar.dart';

class SongBanner extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final bool isPlaying;

  const SongBanner({super.key, required this.audioPlayer, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          useSafeArea: true,
          context: context,
          enableDrag: true,
          builder: (BuildContext context) {
            return StreamBuilder<int?>(
              stream: audioPlayer.currentIndexStream,
              builder: (context, snapshot) {
                final int? currentIndex = snapshot.data;

                if (currentIndex == null) { return const SizedBox.shrink(); }

                final MediaItem currentMetadata = audioPlayer.sequence?[currentIndex].tag;
                return songSheet(currentMetadata, screenWidth);
              },
            );
          },
        );
      },
      child: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white, width: 1.0))),
        child: StreamBuilder<int?>(
          stream: audioPlayer.currentIndexStream,
          builder: (context, snapshot) {
            final int? currentIndex = snapshot.data;

            if (currentIndex == null) { return const SizedBox.shrink(); }
            
            final MediaItem currentMetadata = audioPlayer.sequenceState?.sequence[currentIndex].tag;
            return songBanner(currentMetadata, screenWidth);
          },
        ),
      ),
    );
  }

  Container songBanner(MediaItem metadata, double screenWidth) {
    final double imgWidth = Artworks.artworkSmallSize;
    const double playBtnWidth = 50;
    final double availableWidth = screenWidth - (imgWidth - playBtnWidth)/2;

    return Container(
      width: screenWidth,
      color: ThemeColors.backgroundOled,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        leading: Artworks.artworkStyle(int.parse(metadata.id), imgWidth),
        title: MarqueeTitle(title: metadata.title, availableWidth: availableWidth, textStyle: Styles.subtitleLarge.copyWith(color: ThemeColors.primaryColor)),
        subtitle: MarqueeSubtitle(album: metadata.album, artist: metadata.artist, availableWidth: availableWidth, textStyle: Styles.subtitleMedium.copyWith(color: ThemeColors.primaryColor)),
        trailing: SizedBox(width: playBtnWidth, height: playBtnWidth, child: PlayButton(audioPlayer: audioPlayer)),
      ),
    );
  }

  Container songSheet(MediaItem metadata, double screenWidth) {
    const double padding = 25;
    final double imgWidth = screenWidth - 2*padding;
    
    return Container(
      color: ThemeColors.backgroundOled,
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Artworks.artworkStyle(int.parse(metadata.id), imgWidth),
          AudioProgressBar(positionDataStream: AudioStreamUtils.getPositionDataStream(audioPlayer), audioPlayer: audioPlayer),
          MarqueeTitle(title: metadata.title, availableWidth: screenWidth, textStyle: Styles.titleMedium.copyWith(color: ThemeColors.primaryColor)),
          MarqueeSubtitle(album: metadata.album, artist: metadata.artist, availableWidth: screenWidth, textStyle: Styles.labelLarge.copyWith(color: ThemeColors.primaryColor)),
          Controls(audioPlayer: audioPlayer),
        ],
      ),
    );
  }
}
