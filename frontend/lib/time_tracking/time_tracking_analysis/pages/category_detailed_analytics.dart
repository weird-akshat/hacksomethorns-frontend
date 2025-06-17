import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/time_entry_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryDetailedAnalytics extends StatefulWidget {
  const CategoryDetailedAnalytics({super.key});

  @override
  State<CategoryDetailedAnalytics> createState() =>
      _CategoryDetailedAnalyticsState();
}

class _CategoryDetailedAnalyticsState extends State<CategoryDetailedAnalytics> {
  @override
  late List<ChartData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    data = [
      ChartData('CHN', 12),
      ChartData('GER', 15),
      ChartData('RUS', 30),
      ChartData('BRZ', 6.4),
      ChartData('IND', 14)
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  List<TimeEntry> list = [
    TimeEntry(
      description: "Morning workout",
      timeEntryId: "te1",
      userId: "u1",
      startTime: DateTime(2025, 6, 17, 6, 0),
      endTime: DateTime(2025, 6, 17, 7, 0),
      categoryId: 101,
      categoryName: "Health",
    ),
    TimeEntry(
      description: "Work on Flutter app",
      timeEntryId: "te2",
      userId: "u1",
      startTime: DateTime(2025, 6, 17, 9, 0),
      endTime: DateTime(2025, 6, 17, 11, 30),
      categoryId: 102,
      categoryName: "Development",
    ),
    TimeEntry(
      description: "Team meeting",
      timeEntryId: "te3",
      userId: "u1",
      startTime: DateTime(2025, 6, 17, 12, 0),
      endTime: DateTime(2025, 6, 17, 13, 0),
      categoryId: 103,
      categoryName: "Meetings",
    ),
    TimeEntry(
      description: "Lunch and break",
      timeEntryId: "te4",
      userId: "u1",
      startTime: DateTime(2025, 6, 17, 13, 0),
      endTime: DateTime(2025, 6, 17, 14, 0),
      categoryId: 104,
      categoryName: "Break",
    ),
    TimeEntry(
      description: "Reading ML book",
      timeEntryId: "te5",
      userId: "u1",
      startTime: DateTime(2025, 6, 17, 15, 0),
      endTime: DateTime(2025, 6, 17, 16, 15),
      categoryId: 105,
      categoryName: "Learning",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData('David', 25),
      ChartData('Steve', 38),
      ChartData('Jack', 34),
      ChartData('Others', 52)
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Detailed Category Report"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Duration'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Start Time: '),
                      Text('End time'),
                    ],
                  ),
                ),
                SfCircularChart(
                  series: <CircularSeries>[
                    // Render pie chart
                    PieSeries<ChartData, String>(
                        dataSource: chartData,
                        pointColorMapper: (ChartData data, _) => data.color,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y)
                  ],
                ),
                SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis:
                        NumericAxis(minimum: 0, maximum: 40, interval: 10),
                    tooltipBehavior: _tooltip,
                    series: <CartesianSeries<ChartData, String>>[
                      BarSeries<ChartData, String>(
                          dataSource: data,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          name: 'Gold',
                          color: Color.fromRGBO(8, 142, 255, 1))
                    ]),
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return TimeEntryWidget(timeEntry: list[index]);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}
