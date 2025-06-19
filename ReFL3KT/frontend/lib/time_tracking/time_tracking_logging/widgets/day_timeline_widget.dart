// day_timeline_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/timelog_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/time_entry_widget.dart';

class DayTimelineWidget extends StatelessWidget {
  const DayTimelineWidget({super.key, required this.date, required this.list});
  final DateTime date;
  final List<TimeEntry> list;

  @override
  Widget build(BuildContext context) {
    return Consumer<TimelogProvider>(
      builder: (context, timelogProvider, child) => Column(
        crossAxisAlignment: dayTimelineWidgetCrossAxisAlignment,
        children: [
          Padding(
            padding: const EdgeInsets.all(dayTimelineWidgetPadding),
            child: Text(
              "${date.day}/${date.month}/${date.year}",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height *
                    dayTimelineWidgetDateFontSize,
                fontWeight: dayTimelineWidgetDateFontWeight,
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? dayTimelineWidgetDateColorDark
                    : dayTimelineWidgetDateColorLight,
              ),
            ),
          ),
          AnimationLimiter(
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  print(list[index].endTime);
                  return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                            child: list[index].endTime ==
                                        DateTime(1970, 1, 1, 5, 30) ||
                                    list[index].endTime == null
                                ? SizedBox()
                                : TimeEntryWidget(
                                    timeEntry: list[index],
                                  )),
                      ));
                }),
          )
        ],
      ),
    );
  }
}
