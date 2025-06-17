import 'package:flutter/material.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/day_timeline_widget.dart';
import 'package:provider/provider.dart';
// import 'package:frontend/time_tracking/pages/configuration.dart';

class TimelineWidget extends StatelessWidget {
  TimelineWidget(this.map, {super.key});

  final map;

  // Day 1 (Yesterday)

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Provider.of<ThemeProvider>(context).isDarkMode
          ? scaffoldColorDark
          : scaffoldColorLight,
      child: ListView.builder(
        physics: timelineWidgetScrollPhysics,
        shrinkWrap: timelineWidgetShrinkWrap,
        itemCount: map.length,
        itemBuilder: (context, index) => DayTimelineWidget(
          date: map.keys.elementAt(index),
          list: map[map.keys.elementAt(index)]!,
        ),
      ),
    );
  }
}
