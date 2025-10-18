import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingMultiSlider extends StatefulWidget {
  final String title;
  final String description;
  final List<String> labels;
  final List<double> values;
  final void Function(List<double> values)? onChanged;

  const SettingMultiSlider({super.key, required this.title, required this.description, required this.labels, required this.values, this.onChanged});

  @override
  State<SettingMultiSlider> createState() => _SettingMultiSliderState();
}

class _SettingMultiSliderState extends State<SettingMultiSlider> {
  late List<String> labels;
  late List<double> values;
  late List<double> thumbPositions;

  final double trackHeight = 5;
  final double thumbRadius = 10;

  double? _startGlobalDx;
  double? _startStopNormalized;
  int? _draggingThumbIndex;

  @override
  void initState() {
    super.initState();
    labels = widget.labels;
    values = widget.values;
  }

  @override
  void didUpdateWidget(covariant SettingMultiSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.values, oldWidget.values)) {
      values = List.from(widget.values);
    }
  }
  
  void _onGlobalDragStart(DragStartDetails details, double barWidth) {
    final double tapDx = (details.localPosition.dx / barWidth).clamp(0.0, 1.0);
    final List<double> stops = _normalizedStops();

    double minDistance = double.infinity;
    List<int> candidates = [];

    for (int i = 1; i < stops.length - 1; i++) {
      final double d = (stops[i] - tapDx).abs();
      if (d < minDistance) {
        minDistance = d;
        candidates = [i];
      } else if (d == minDistance) {
        candidates.add(i);
      }
    }

    int closestIndex;
    if (candidates.length > 1) {
      final double clusterCenter = candidates.map((i) => stops[i]).reduce((a, b) => a + b) / candidates.length;
      closestIndex = (tapDx < clusterCenter) ? candidates.first : candidates.last;
    } else {
      closestIndex = candidates.first;
    }

    _draggingThumbIndex = closestIndex;
    _startGlobalDx = details.globalPosition.dx;
    _startStopNormalized = stops[closestIndex];
  }

  void _onGlobalDragUpdate(DragUpdateDetails details, double barWidth, int? index) {
    if (index == null || _startGlobalDx == null || _startStopNormalized == null) return;

    final double dx = details.globalPosition.dx - _startGlobalDx!;
    final double deltaNormalized = dx / barWidth;

    final List<double> stops = _normalizedStops();

    final double leftLimit = stops[index - 1];
    final double rightLimit = stops[index + 1];

    final double newStop = (_startStopNormalized! + deltaNormalized).clamp(leftLimit, rightLimit);

    final double leftSegment = newStop - stops[index - 1];
    final double rightSegment = stops[index + 1] - newStop;
    final double total = values[index - 1] + values[index];
    final double leftRatio = (leftSegment + rightSegment) > 0 ? leftSegment / (leftSegment + rightSegment) : 0.5;

    setState(() {
      values[index - 1] = _round(total * leftRatio);
      values[index] = _round(total * (1 - leftRatio));
    });
  }

  void _onGlobalDragEnd(DragEndDetails details) {
    if (_draggingThumbIndex == null) return;

    _startGlobalDx = null;
    _startStopNormalized = null;
    _draggingThumbIndex = null;

    widget.onChanged?.call(List.from(values));
  }

  List<double> _normalizedStops() {
    final List<double> stops = [0.0];
    for (final value in values) {
      stops.add(stops.last + value);
    }
    return stops;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.bodyLarge),
          Text(widget.description, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.tertiary)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final List<double> stops = _normalizedStops();

                return SizedBox(
                  height: 30,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) => _onGlobalDragStart(details, width),
                    onPanUpdate: (details) => _onGlobalDragUpdate(details, width, _draggingThumbIndex),
                    onPanEnd: _onGlobalDragEnd,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: trackHeight,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(trackHeight),
                          ),
                        ),
                        for (int i = 1; i < values.length; i++)
                          Positioned(
                            left: width * stops[i] - thumbRadius,
                            child: Container(
                              width: 2 * thumbRadius,
                              height: 2 * thumbRadius,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildCaption(),
        ],
      ),
    );
  }

  Row _buildCaption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        values.length,
        (i) => Column(
          children: [
            Text(
              labels[i],
              style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.tertiary),
            ),
            Text(
              '${(values[i] * 100).toStringAsFixed(0)} %',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.tertiary),
            ),
          ],
        ),
      ),
    );
  }

  double _round(double value) => double.parse(value.toStringAsFixed(2));
}