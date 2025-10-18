import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:shadow_garden/database/database_service.dart';
import 'package:shadow_garden/models/report.dart';
import 'package:shadow_garden/providers/audio_provider.dart';
import 'package:shadow_garden/providers/settings_service.dart';
import 'package:shadow_garden/utils/translator.dart';
import 'package:shadow_garden/utils/styles.dart';
import 'package:shadow_garden/utils/utility.dart';
import 'package:shadow_garden/widgets/overlays.dart';
import 'package:shadow_garden/widgets/artworks.dart';
import 'package:shadow_garden/widgets/text_display.dart';

class StatisticsScreen extends StatefulWidget {
  final AudioProvider audioProvider;

  const StatisticsScreen({super.key, required this.audioProvider});

  @override
  StatisticsScreenState createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  final SettingsService _settings = SettingsService();
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Report>(
      future: _db.getReport(),
      builder: (BuildContext context, AsyncSnapshot<Report> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        Report? report = snapshot.data;
        if (snapshot.hasError || report == null) {
          return Center(child: Text('errorLoadingStats'.t(), style: Theme.of(context).textTheme.headlineSmall));
        }

        final List<Song> songs = report.songs;
        final Statistics statistics = report.statistics;
        final List<String> globalStats = _settings.getGlobalStats();
        
        final int nbListens = _calculateNbOfListens(globalStats, statistics);
        final int listeningTime = _calculateListeningTime(globalStats, statistics);
        
        final Map<int, int> keyToSongId = {};
        final List<SongModel> songModels = widget.audioProvider.songs;
        for (final song in songModels) { keyToSongId[Utility.fastHash(song.album, song.title, song.artist)] = song.id; }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            statisticText('textTotalListenTime'.t(), 'textListeningTime'.t([(listeningTime / 60).toStringAsFixed(0), (listeningTime / 3600).toStringAsFixed(0)]), Icons.access_time_rounded),
            statisticText('textTotalListenNb'.t(), nbListens.toString(), Icons.remove_red_eye_rounded),
            statisticText('textTotalSongs'.t([songs.length])),
            Expanded(
              child: Scrollbar(
                thickness: DesignSystem.scrollbarThickness,
                thumbVisibility: true,
                radius: const Radius.circular(20),
                interactive: true,
                child: ListView.builder(
                  primary: false,
                  padding: const EdgeInsets.only(right: DesignSystem.scrollbarThickness),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final Song song = songs[index];
                    final int? songId = keyToSongId[song.key];

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.only(left: 16, top: 4, right: 0, bottom: 4),
                      leading: songId != null ? SongArtwork(songId: songId, imgWidth: DesignSystem.artworkSmallSize) : const ErrorArtwork(imgWidth: DesignSystem.artworkSmallSize),
                      title: TitleText(
                        title: '${song.score.toStringAsFixed(3)} - ${song.title}',
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      subtitle: TitleText(
                        title: 'textSongStats'.t([song.nbOfListens, (song.listeningTime / (song.nbOfListens * song.duration) * 100).toStringAsFixed(0), (song.daysAgo ~/ 30)]),
                        textStyle: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.tertiary),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => Dialogs.deletionDialog(context, () async {
                          bool success = await _db.clearData(song.id);
                          if (success) { setState(() => songs.remove(song)); }
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Padding statisticText(String label, [String? value, IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 16),
              Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          if (value != null) Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  int _calculateNbOfListens(List<String> globalStats, Statistics statistics) {
    return int.parse(globalStats[0]) + statistics.totalNbOfListens;
  }
  int _calculateListeningTime(List<String> globalStats, Statistics statistics) {
    return int.parse(globalStats[1]) + statistics.totalListeningTime;
  }
}