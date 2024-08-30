import 'package:flutter/material.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/style/common_text.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:shadow_garden/widgets/text_display.dart';

class StatisticsScreen extends StatefulWidget {

  const StatisticsScreen({super.key});

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
    return FutureBuilder<Map<String, dynamic>>(
      future: _dataSongs,
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        const double scrollbarThickness = 10.0;
    
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final List<Song> songs = snapshot.data?['songs'] ?? [];
          final Map<String, int> data = snapshot.data?['data'] ?? {};
    
          return Column(
            children: [
              statisticText(Texts.textTrackingDate, _settings.getMonitoringDate()),
              statisticText(Texts.textTotalListenNb, (data['totalNbOfListens'] ?? 0).toString()),
              statisticText(Texts.textTotalListenTime, '${((data['totalListeningTime'] ?? 0) / 60).toStringAsFixed(0)} min (${((data['totalListeningTime'] ?? 0) / 3600).toStringAsFixed(0)} h)'),
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
                      return ListTile(
                        leading: Artworks.artworkStyle(song.songId, Artworks.artworkSmallSize),
                        title: TitleText(title: '${song.smartScore.toStringAsFixed(3)} - ${song.title}', textStyle: Styles.songHomeTitle(false)),
                        subtitle: Text('${song.nbOfListens} listens - ${(song.listeningTime / (song.nbOfListens * song.duration) * 100).toStringAsFixed(0)} % listened - ${song.daysAgo ~/ 30} mos ago', style: Styles.labelLarge.copyWith(color: ThemeColors.primaryColor)),
                        iconColor: ThemeColors.primaryColor,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
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
}