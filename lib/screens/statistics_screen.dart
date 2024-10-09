import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/style/common_text.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:shadow_garden/utils/functions.dart';
import 'package:shadow_garden/widgets/alerts.dart';
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
  late Future<Map<String, dynamic>> _dataSongs;

  @override
  void initState() {
    super.initState();
    _dataSongs = _db.getDataSongs();
  }

  @override
  Widget build(BuildContext context) {
    const double scrollbarThickness = 10.0;

    return FutureBuilder<Map<String, dynamic>>(
      future: _dataSongs,
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(Texts.errorLoadingStats, style: Theme.of(context).textTheme.headlineSmall));
        }

        final List<Song> songs = snapshot.data!['songs'] ?? [];
        final Map<String, int> data = snapshot.data!['data'] ?? {};
        final List<String> globalStats = _settings.getGlobalStats();
        
        final int nbListens = _calculateNbOfListens(globalStats, data);
        final int listeningTime = _calculateListeningTime(globalStats, data);
        
        final Map<int, int> keyToSongId = {};
        final List<SongModel> songModels = widget.audioProvider.songs;
        for (final song in songModels) { keyToSongId[Functions.fastHash(song.album, song.title, song.artist)] = song.id; }

        return Column(
          children: [
            statisticText(Texts.textTrackingDate, _settings.getMonitoringDate()),
            statisticText(Texts.textTotalListenNb, nbListens.toString()),
            statisticText(Texts.textTotalListenTime, '${(listeningTime / 60).toStringAsFixed(0)} min (${(listeningTime / 3600).toStringAsFixed(0)} h)'),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: Scrollbar(
                thickness: scrollbarThickness,
                thumbVisibility: true,
                radius: const Radius.circular(20),
                interactive: true,
                child: ListView.builder(
                  padding: const EdgeInsets.only(right: scrollbarThickness),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final Song song = songs[index];
                    final int? songId = keyToSongId[song.key];

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.only(left: 16, top: 4, right: 0, bottom: 4),
                      leading: songId != null ? Artworks.artworkStyle(context, songId, Artworks.artworkSmallSize) : Artworks.errorArtworkStyle(context, Artworks.artworkSmallSize),
                      title: TitleText(title: '${song.score.toStringAsFixed(3)} - ${song.title}', textStyle: Styles.songHomeTitle(context, false)),
                      subtitle: Text(
                        '${song.nbOfListens} listens • ${(song.listeningTime / (song.nbOfListens * song.duration) * 100).toStringAsFixed(0)} % listened • ${song.daysAgo ~/ 30} mos ago',
                        style: Theme.of(context).textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => Alerts.deletionDialog(context, () async {
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

  Padding statisticText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  int _calculateNbOfListens(List<String> globalStats, Map<String, int> data) {
    return int.parse(globalStats[0]) + (data['totalNbOfListens'] ?? 0);
  }
  int _calculateListeningTime(List<String> globalStats, Map<String, int> data) {
    return int.parse(globalStats[1]) + (data['totalListeningTime'] ?? 0);
  }
}