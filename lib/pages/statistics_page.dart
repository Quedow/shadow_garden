import 'package:flutter/material.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/screens/statistics_screen.dart';
import 'package:shadow_garden/style/common_text.dart';

class StatisticsPage extends StatefulWidget {
  final AudioProvider audioProvider;

  const StatisticsPage({super.key, required this.audioProvider});

  @override
  StatisticsPageState createState() => StatisticsPageState();
}

class StatisticsPageState extends State<StatisticsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Texts.textStatisticsBar),
        bottom: PreferredSize(preferredSize: Size.zero, child: Container(color: Theme.of(context).colorScheme.secondary, height: 1.0)),
      ),
      body: StatisticsScreen(audioProvider: widget.audioProvider),
    );
  }
}