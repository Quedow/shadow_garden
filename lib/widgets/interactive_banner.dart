import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shadow_garden/utils/audio_stream_utils.dart';
import 'package:shadow_garden/utils/styles.dart';
import 'package:shadow_garden/widgets/artworks.dart';
import 'package:shadow_garden/widgets/text_display.dart';
import 'package:shadow_garden/widgets/controls.dart';
import 'package:shadow_garden/widgets/audio_progress_bar.dart';

class InteractiveBanner extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const InteractiveBanner({super.key, required this.audioPlayer});

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

                final MediaItem currentMetadata = audioPlayer.sequence[currentIndex].tag;
                return SongSheet(audioPlayer: audioPlayer, metadata: currentMetadata, screenWidth: screenWidth);
              },
            );
          },
        );
      },
      child: SongBanner(audioPlayer: audioPlayer, screenWidth: screenWidth),
    );
  }
}

class SongBanner extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final double screenWidth;

  const SongBanner({super.key, required this.audioPlayer, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    const double imgWidth = DesignSystem.artworkBannerSize;
    const double playBtnWidth = 45;
    final double availableWidth = screenWidth - (imgWidth - playBtnWidth)/2;

    return Container(
      decoration: const BoxDecoration(
        color: ThemeColors.darkPrimaryColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: StreamBuilder<SequenceState?>(
        stream: audioPlayer.sequenceStateStream,
        builder: (context, snapshot) {
          final int? currentIndex = snapshot.data?.currentIndex;

          if (currentIndex == null) { return const SizedBox.shrink(); }
          
          final MediaItem currentMetadata = audioPlayer.sequenceState.sequence[currentIndex].tag;
          return SizedBox(
            width: screenWidth,
            child: ListTile(
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 15.0),
              leading: SongArtwork(songId: int.parse(currentMetadata.id), imgWidth: imgWidth),
              title: MarqueeSingle(title: currentMetadata.title, availableWidth: availableWidth, textStyle: Theme.of(context).textTheme.labelLarge),
              subtitle: MarqueeSingle(title: currentMetadata.artist ?? '', availableWidth: availableWidth, textStyle: Theme.of(context).textTheme.labelMedium),
              trailing: SizedBox(width: playBtnWidth, height: playBtnWidth, child: PlayButton(audioPlayer: audioPlayer)),
            ),
          );
        },
      ),
    );
  }
}

class SongSheet extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final MediaItem metadata;
  final double screenWidth;

  const SongSheet({super.key, required this.audioPlayer, required this.metadata, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    const double padding = 25;
    final double imgWidth = screenWidth - 2*padding;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SongArtwork(songId: int.parse(metadata.id), imgWidth: imgWidth),
          AudioProgressBar(positionDataStream: AudioStreamUtils.getPositionDataStream(audioPlayer), audioPlayer: audioPlayer),
          MarqueeSingle(title: metadata.title, availableWidth: screenWidth, textStyle: Theme.of(context).textTheme.titleLarge!),
          MarqueeMultiple(labels: [metadata.album, metadata.artist], availableWidth: screenWidth, textStyle: Theme.of(context).textTheme.labelMedium!),
          Controls(audioPlayer: audioPlayer),
        ],
      ),
    );
  }
}
