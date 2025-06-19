import 'package:flutter/material.dart';
import 'package:frontend/api_methods/get_category_analytics.dart';
import 'package:frontend/time_tracking/entities/category.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/showcase_time_entry_widget.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/time_entry_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryDetailedAnalytics extends StatefulWidget {
  const CategoryDetailedAnalytics(
      {super.key,
      required this.category,
      required this.endTime,
      required this.startTime});
  final DateTime startTime;
  final DateTime endTime;
  final Category category;

  @override
  State<CategoryDetailedAnalytics> createState() =>
      _CategoryDetailedAnalyticsState();
}

class _CategoryDetailedAnalyticsState extends State<CategoryDetailedAnalytics> {
  late TooltipBehavior _tooltip;

  // API integration variables
  Map<String, dynamic>? categoryAnalyticsData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    _tooltip = TooltipBehavior(enable: true);

    // Fetch API data
    _fetchCategoryAnalytics();
  }

  Future<void> _fetchCategoryAnalytics() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await getCategoryAnalytics(
        userId: "1", // Assuming category has userId
        categoryId: widget.category.categoryId,
        startTime: widget.startTime,
        endTime: widget.endTime,
      );

      setState(() {
        categoryAnalyticsData = data;
        isLoading = false;
      });

      if (data == null) {
        setState(() {
          errorMessage = "Failed to fetch category analytics";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.category.name} Report",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading analytics...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCategoryAnalytics,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Main content when data is loaded
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    if (categoryAnalyticsData == null) {
      return Center(child: Text('No data available'));
    }

    print('Category Analytics Data: $categoryAnalyticsData');

    // Prepare pie chart data from grouped_entries
    final List<PieChartData> pieChartData = _preparePieChartData();
    print('Pie Chart Data Length: ${pieChartData.length}');

    // Prepare bar chart data from daily_stats
    final List<BarChartData> barChartData = _prepareBarChartData();
    print('Bar Chart Data Length: ${barChartData.length}');

    // Prepare time entries list
    final List<TimeEntry> timeEntries = _prepareTimeEntries();
    print('Time Entries Length: ${timeEntries.length}');

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Start Time: ${widget.startTime.toString().split(' ')[0]}'),
                  Text('End Time: ${widget.endTime.toString().split(' ')[0]}'),
                ],
              ),
            ),

            // Display total duration from API data
            Text(
              'Total Duration: ${categoryAnalyticsData!['total_duration']}',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),

            // Show API data summary
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category: ${categoryAnalyticsData!['category']['_name']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                          'Total Entries: ${categoryAnalyticsData!['time_entries'].length}'),
                      Text(
                          'Grouped Entries: ${categoryAnalyticsData!['grouped_entries'].length}'),
                    ],
                  ),
                ),
              ),
            ),

            // Pie Chart for grouped entries
            Text(
              'Time Entry Distribution',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            if (pieChartData.isNotEmpty)
              SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                series: <CircularSeries>[
                  PieSeries<PieChartData, String>(
                    dataSource: pieChartData,
                    pointColorMapper: (PieChartData data, _) => data.color,
                    xValueMapper: (PieChartData data, _) => data.description,
                    yValueMapper: (PieChartData data, _) =>
                        data.durationInMinutes,
                    dataLabelMapper: (PieChartData data, _) =>
                        '${data.percentage.toStringAsFixed(1)}%',
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                    enableTooltip: true,
                  )
                ],
              )
            else
              Container(
                height: 200,
                child: Center(
                  child: Text('No pie chart data available'),
                ),
              ),

            // Bar Chart for daily stats
            Text(
              'Daily Time Spent',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            if (barChartData.isNotEmpty)
              SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  labelFormat: '{value} min',
                  title: AxisTitle(text: 'Time (minutes)'),
                ),
                tooltipBehavior: _tooltip,
                series: <CartesianSeries<BarChartData, String>>[
                  BarSeries<BarChartData, String>(
                    dataSource: barChartData,
                    xValueMapper: (BarChartData data, _) => data.date,
                    yValueMapper: (BarChartData data, _) =>
                        data.durationInMinutes,
                    name: 'Time Spent',
                    color: Color.fromRGBO(8, 142, 255, 1),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                    ),
                  )
                ],
              )
            else
              Container(
                height: 200,
                child: Center(
                  child: Text('No bar chart data available'),
                ),
              ),

            // Time entries list
            Text(
              'Time Entries (${timeEntries.length})',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            if (timeEntries.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: timeEntries.length,
                itemBuilder: (context, index) {
                  return ShowcaseTimeEntryWidget(timeEntry: timeEntries[index]);
                },
              )
            else
              Container(
                height: 100,
                child: Center(
                  child: Text('No time entries available'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartData> _preparePieChartData() {
    if (categoryAnalyticsData == null) {
      print('Category analytics data is null');
      return [];
    }

    try {
      final groupedEntries = categoryAnalyticsData!['grouped_entries'] as List;
      print('Grouped entries: $groupedEntries');

      final totalDurationString =
          categoryAnalyticsData!['total_duration'] as String;
      final totalMinutes = _parseDurationToMinutes(totalDurationString);
      print('Total minutes: $totalMinutes');

      final colors = [
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal,
        Colors.pink,
        Colors.indigo,
        Colors.amber,
        Colors.cyan,
      ];

      return groupedEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final description = item['_description'] ?? 'Untitled';
        final durationString = item['_duration'] as String;
        final durationInMinutes = _parseDurationToMinutes(durationString);
        final percentage =
            totalMinutes > 0 ? (durationInMinutes / totalMinutes) * 100 : 0.0;

        print(
            'Pie chart item - Description: $description, Duration: $durationInMinutes, Percentage: $percentage');

        return PieChartData(
          description: description,
          durationInMinutes: durationInMinutes,
          percentage: percentage,
          color: colors[index % colors.length],
        );
      }).toList();
    } catch (e) {
      print('Error preparing pie chart data: $e');
      return [];
    }
  }

  List<BarChartData> _prepareBarChartData() {
    if (categoryAnalyticsData == null) {
      print('Category analytics data is null for bar chart');
      return [];
    }

    try {
      final dailyStats =
          categoryAnalyticsData!['daily_stats'] as Map<String, dynamic>;
      print('Daily stats: $dailyStats');

      return dailyStats.entries.map((entry) {
        final date = entry.key;
        final durationString = entry.value as String;
        final durationInMinutes = _parseDurationToMinutes(durationString);

        print('Bar chart item - Date: $date, Duration: $durationInMinutes');

        return BarChartData(
          date: date,
          durationInMinutes: durationInMinutes,
        );
      }).toList();
    } catch (e) {
      print('Error preparing bar chart data: $e');
      return [];
    }
  }

  List<TimeEntry> _prepareTimeEntries() {
    if (categoryAnalyticsData == null) {
      print('Category analytics data is null for time entries');
      return [];
    }

    try {
      final timeEntries = categoryAnalyticsData!['time_entries'] as List;
      print('Time entries from API: ${timeEntries.length} entries');

      return timeEntries
          .map((entry) {
            print('Time entry: $entry');
            return TimeEntry(
              timeEntryId: entry['_timeEntryId'] ?? '',
              description: entry['_description'] ?? 'Untitled',
              userId: widget.category.userId,
              startTime: DateTime.parse(entry['_startTime']),
              endTime: DateTime.parse(entry['_endTime']),
              categoryId: entry['_categoryId'] ?? 0,
              categoryName: entry['_categoryName'] ?? '',
            );
          })
          .cast<TimeEntry>()
          .toList();
    } catch (e) {
      print('Error preparing time entries: $e');
      return [];
    }
  }

  double _parseDurationToMinutes(String duration) {
    // Parse duration string like "0:43:31.438333" to minutes
    print('Parsing duration: $duration');

    try {
      final parts = duration.split(':');
      if (parts.length >= 3) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final secondsParts = parts[2].split('.');
        final seconds = int.tryParse(secondsParts[0]) ?? 0;

        final totalMinutes = (hours * 60) + minutes + (seconds / 60);
        print('Parsed duration: $totalMinutes minutes');
        return totalMinutes;
      }
    } catch (e) {
      print('Error parsing duration: $e');
    }

    return 0.0;
  }
}

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}

class PieChartData {
  PieChartData({
    required this.description,
    required this.durationInMinutes,
    required this.percentage,
    required this.color,
  });

  final String description;
  final double durationInMinutes;
  final double percentage;
  final Color color;
}

class BarChartData {
  BarChartData({
    required this.date,
    required this.durationInMinutes,
  });

  final String date;
  final double durationInMinutes;
}
