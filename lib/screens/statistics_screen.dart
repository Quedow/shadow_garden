import 'package:flutter/material.dart';
import 'package:shadow_garden/model/song.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:shadow_garden/widgets/text_display.dart';

class StatisticsScreen extends StatefulWidget {

  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  StatisticsScreenState createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseService _db = DatabaseService();
  late Future<List<Song>> futureSongs;

  @override
  void initState() {
    super.initState();
    futureSongs = _db.getAllSongs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Song>>(
      future: futureSongs,
      builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
        const double scrollbarThickness = 10.0;
    
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final List<Song> songs = snapshot.data ?? [];
    
          return Scrollbar(
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
                  title: TitleText(title: "${song.score} - ${song.label}", textStyle: Styles.songHomeTitle(false)), // DEBUG TEST
                  subtitle: Text("${song.nbOfListens} listens - ${(song.listeningRate * 100).toStringAsFixed(1)} % listened - ${song.dateAdded} months ago", style: Styles.songSheetSubtitle),
                  iconColor: ThemeColors.primaryColor,
                );
              },
            ),
          );
        }
      },
    );
  }
}