import 'package:flutter/material.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/style/common_text.dart';
import 'package:shadow_garden/style/style.dart';
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
          return const Center(child: CircularProgressIndicator(color: ThemeColors.accentColor));
        }

        if (snapshot.hasError) {
          return Center(child: Text(Texts.errorLoadingStats, style: Styles.titleLarge.copyWith(color: ThemeColors.primaryColor)));
        }

        final List<Song> songs = snapshot.data!['songs'] ?? [];
        final Map<String, int> data = snapshot.data!['data'] ?? {};
        final List<String> globalStats = _settings.getGlobalStats();
        
        int nbListens = _calculateNbOfListens(globalStats, data);
        int listeningTime = _calculateListeningTime(globalStats, data);
        Set<int> songIds = widget.audioProvider.songs.map((song) => song.id).toSet();

        return Column(
          children: [
            statisticText(Texts.textTrackingDate, _settings.getMonitoringDate()),
            statisticText(Texts.textTotalListenNb, nbListens.toString()),
            statisticText(Texts.textTotalListenTime, '${(listeningTime / 60).toStringAsFixed(0)} min (${(listeningTime / 3600).toStringAsFixed(0)} h)'),
            Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor.withOpacity(0.5)),
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
                    bool stillExists = songIds.contains(song.songId);

                    return ListTile(
                      dense: true,
                      iconColor: ThemeColors.primaryColor,
                      contentPadding: const EdgeInsets.only(left: 16, top: 4, right: 0, bottom: 4),
                      leading: stillExists ? Artworks.artworkStyle(song.songId, Artworks.artworkSmallSize) : Artworks.errorArtworkStyle(Artworks.artworkSmallSize),
                      title: TitleText(title: '${song.smartScore.toStringAsFixed(3)} - ${song.title}', textStyle: Styles.songHomeTitle(false)),
                      subtitle: Text(
                        '${song.nbOfListens} listens - ${(song.listeningTime / (song.nbOfListens * song.duration) * 100).toStringAsFixed(0)} % listened - ${song.daysAgo ~/ 30} mos ago',
                        style: Styles.labelLarge.copyWith(color: ThemeColors.primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis,
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
          Text(label, style: Styles.subtitleMedium.copyWith(color: ThemeColors.primaryColor)),
          Text(value, style: Styles.subtitleMedium.copyWith(color: ThemeColors.primaryColor)),
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