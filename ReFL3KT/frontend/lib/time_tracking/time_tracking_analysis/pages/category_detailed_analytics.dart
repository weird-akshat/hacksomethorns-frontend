import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/api_methods/get_category_analytics.dart';
import 'package:frontend/time_tracking/entities/category.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/showcase_time_entry_widget.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/time_entry_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class CategoryDetailedAnalytics extends StatefulWidget {
  const CategoryDetailedAnalytics({
    super.key,
    required this.category,
    required this.endTime,
    required this.startTime,
  });
  final DateTime startTime;
  final DateTime endTime;
  final Category category;

  @override
  State<CategoryDetailedAnalytics> createState() =>
      _CategoryDetailedAnalyticsState();
}

class _CategoryDetailedAnalyticsState extends State<CategoryDetailedAnalytics> {
  late TooltipBehavior _tooltip;
  final GlobalKey<SfCircularChartState> _pieChartKey = GlobalKey();
  final GlobalKey<SfCartesianChartState> _barChartKey = GlobalKey();

  // API integration variables
  Map<String, dynamic>? categoryAnalyticsData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(enable: true);
    _fetchCategoryAnalytics();
  }

  Future<void> _fetchCategoryAnalytics() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await getCategoryAnalytics(
        userId: "1",
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

  Future<void> _exportChartsToPdf() async {
    try {
      final ui.Image? pieImage =
          await _pieChartKey.currentState?.toImage(pixelRatio: 3.0);
      final ByteData? pieBytes =
          await pieImage?.toByteData(format: ui.ImageByteFormat.png);

      final ui.Image? barImage =
          await _barChartKey.currentState?.toImage(pixelRatio: 3.0);
      final ByteData? barBytes =
          await barImage?.toByteData(format: ui.ImageByteFormat.png);

      final PdfDocument document = PdfDocument();

      final PdfPage piePage = document.pages.add();
      final PdfGraphics pieGraphics = piePage.graphics;
      pieGraphics.drawString(
          '${widget.category.name} - Time Entry Distribution',
          PdfStandardFont(PdfFontFamily.helvetica, 20),
          bounds: Rect.fromLTWH(0, 20, piePage.getClientSize().width, 30));
      if (pieBytes != null) {
        final PdfBitmap pieBitmap = PdfBitmap(pieBytes.buffer.asUint8List());
        pieGraphics.drawImage(pieBitmap,
            Rect.fromLTWH(0, 60, piePage.getClientSize().width, 300));
      }

      final PdfPage barPage = document.pages.add();
      final PdfGraphics barGraphics = barPage.graphics;
      barGraphics.drawString('${widget.category.name} - Daily Time Spent',
          PdfStandardFont(PdfFontFamily.helvetica, 20),
          bounds: Rect.fromLTWH(0, 20, barPage.getClientSize().width, 30));
      if (barBytes != null) {
        final PdfBitmap barBitmap = PdfBitmap(barBytes.buffer.asUint8List());
        barGraphics.drawImage(barBitmap,
            Rect.fromLTWH(0, 60, barPage.getClientSize().width, 300));
      }

      // Save and share PDF
      final List<int> bytes = await document.save();
      document.dispose();

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${widget.category.name}_report.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(path)],
          text: '${widget.category.name} Analytics Report');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to export PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.scaffoldColor,
          appBar: AppBar(
            title: Text(
              "${widget.category.name} Report",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            backgroundColor: themeProvider.scaffoldColor,
            iconTheme: IconThemeData(color: themeProvider.textColor),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.picture_as_pdf),
                onPressed: isLoading ? null : _exportChartsToPdf,
                tooltip: 'Download PDF',
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        themeProvider.primaryAccent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: _buildBody(themeProvider),
          ),
        );
      },
    );
  }

  Widget _buildBody(ThemeProvider themeProvider) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                themeProvider.primaryAccent,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Loading analytics...',
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.textColor,
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryAccent,
                foregroundColor: Colors.white,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _buildMainContent(themeProvider);
  }

  Widget _buildMainContent(ThemeProvider themeProvider) {
    if (categoryAnalyticsData == null) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: themeProvider.textColor),
        ),
      );
    }

    // Prepare pie chart data from grouped_entries
    final List<PieChartData> pieChartData = _preparePieChartData(themeProvider);

    // Prepare bar chart data from daily_stats
    final List<BarChartData> barChartData = _prepareBarChartData();

    // Prepare time entries list
    final List<TimeEntry> timeEntries = _prepareTimeEntries();

    return SingleChildScrollView(
      child: Container(
        color: themeProvider.scaffoldColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start Time: ${widget.startTime.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  Text(
                    'End Time: ${widget.endTime.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                ],
              ),
            ),

            // Display total duration from API data
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 3,
                color: themeProvider.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                    color: themeProvider.borderColor,
                    width: 1,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.primaryAccent.withOpacity(0.1),
                        themeProvider.primaryAccent.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer,
                          color: themeProvider.primaryAccent,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Total Duration: ${_formatDurationString(categoryAnalyticsData!['total_duration'])}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: themeProvider.primaryAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Show API data summary
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 3,
                color: themeProvider.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                    color: themeProvider.borderColor,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: themeProvider.primaryAccent,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Category: ${categoryAnalyticsData!['category']['_name']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: themeProvider.textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: themeProvider.secondaryAccent
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: themeProvider.secondaryAccent
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.list_alt,
                                    color: themeProvider.secondaryAccent,
                                    size: 20,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${categoryAnalyticsData!['time_entries'].length}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: themeProvider.secondaryAccent,
                                    ),
                                  ),
                                  Text(
                                    'Total Entries',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: themeProvider.textColor
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    themeProvider.subtleAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: themeProvider.subtleAccent
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.group_work,
                                    color: themeProvider.subtleAccent,
                                    size: 20,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${categoryAnalyticsData!['grouped_entries'].length}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: themeProvider.subtleAccent,
                                    ),
                                  ),
                                  Text(
                                    'Grouped Entries',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: themeProvider.textColor
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pie Chart for grouped entries
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Time Entry Distribution',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: themeProvider.textColor,
                ),
              ),
            ),
            if (pieChartData.isNotEmpty)
              Container(
                height: 400,
                padding: EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  color: themeProvider.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: themeProvider.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SfCircularChart(
                      key: _pieChartKey,
                      backgroundColor: themeProvider.cardColor,
                      legend: Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        position: LegendPosition.bottom,
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.textColor,
                        ),
                      ),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        format: 'point.x: point.y minutes (point.percentage%)',
                        textStyle: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      series: <CircularSeries>[
                        DoughnutSeries<PieChartData, String>(
                          dataSource: pieChartData,
                          pointColorMapper: (PieChartData data, _) =>
                              data.color,
                          xValueMapper: (PieChartData data, _) =>
                              data.description,
                          yValueMapper: (PieChartData data, _) =>
                              data.durationInMinutes,
                          dataLabelMapper: (PieChartData data, _) =>
                              '${data.percentage.toStringAsFixed(1)}%',
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            useSeriesColor: true,
                            textStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textColor,
                            ),
                            connectorLineSettings: ConnectorLineSettings(
                              type: ConnectorType.curve,
                              length: '10%',
                              color: themeProvider.textColor.withOpacity(0.5),
                            ),
                          ),
                          enableTooltip: true,
                          innerRadius: '40%',
                          radius: '80%',
                          strokeColor: themeProvider.borderColor,
                          strokeWidth: 2,
                        )
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                margin: EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  color: themeProvider.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: themeProvider.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pie_chart_outline,
                          size: 48,
                          color: themeProvider.textColor.withOpacity(0.5),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No pie chart data available',
                          style: TextStyle(
                            color: themeProvider.textColor.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bar Chart for daily stats
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Daily Time Spent',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: themeProvider.textColor,
                ),
              ),
            ),
            if (barChartData.isNotEmpty)
              Container(
                height: 350,
                padding: EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  color: themeProvider.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: themeProvider.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SfCartesianChart(
                      key: _barChartKey,
                      backgroundColor: themeProvider.cardColor,
                      plotAreaBorderWidth: 0,
                      primaryXAxis: CategoryAxis(
                        labelStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.textColor,
                        ),
                        majorGridLines: MajorGridLines(width: 0),
                        axisLine: AxisLine(width: 0),
                        labelRotation: -45,
                      ),
                      primaryYAxis: NumericAxis(
                        labelFormat: '{value} min',
                        title: AxisTitle(
                          text: 'Time (minutes)',
                          textStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textColor,
                          ),
                        ),
                        majorGridLines: MajorGridLines(
                          width: 1,
                          color: themeProvider.borderColor.withOpacity(0.3),
                        ),
                        axisLine: AxisLine(width: 0),
                        labelStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.textColor,
                        ),
                      ),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        format: 'point.x: point.y minutes',
                        textStyle: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          fontSize: 12,
                        ),
                        borderWidth: 0,
                        elevation: 3,
                      ),
                      series: <CartesianSeries<BarChartData, String>>[
                        ColumnSeries<BarChartData, String>(
                          dataSource: barChartData,
                          xValueMapper: (BarChartData data, _) => data.date,
                          yValueMapper: (BarChartData data, _) =>
                              data.durationInMinutes,
                          name: 'Time Spent',
                          gradient: LinearGradient(
                            colors: [
                              themeProvider.primaryAccent.withOpacity(0.8),
                              themeProvider.primaryAccent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelAlignment: ChartDataLabelAlignment.top,
                            textStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textColor,
                            ),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                          spacing: 0.2,
                        )
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                margin: EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  color: themeProvider.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: themeProvider.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_outlined,
                          size: 48,
                          color: themeProvider.textColor.withOpacity(0.5),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No bar chart data available',
                          style: TextStyle(
                            color: themeProvider.textColor.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Time entries list
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Time Entries (${timeEntries.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: themeProvider.textColor,
                ),
              ),
            ),
            if (timeEntries.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 2,
                  color: themeProvider.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: themeProvider.borderColor,
                      width: 1,
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: timeEntries.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: index < timeEntries.length - 1
                              ? Border(
                                  bottom: BorderSide(
                                    color: themeProvider.borderColor
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                )
                              : null,
                        ),
                        child: TimeEntryWidget(timeEntry: timeEntries[index]),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                height: 120,
                margin: EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  color: themeProvider.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: themeProvider.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 48,
                          color: themeProvider.textColor.withOpacity(0.5),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No time entries available',
                          style: TextStyle(
                            color: themeProvider.textColor.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartData> _preparePieChartData(ThemeProvider themeProvider) {
    if (categoryAnalyticsData == null) return [];

    try {
      final groupedEntries = categoryAnalyticsData!['grouped_entries'] as List;
      final totalDurationString =
          categoryAnalyticsData!['total_duration'] as String;
      final totalMinutes = _parseDurationToMinutes(totalDurationString);

      // Theme-aware colors
      final colors = themeProvider.isDarkMode
          ? [
              Color(0xFF4FC3F7), // Light Blue
              Color(0xFFE57373), // Light Red
              Color(0xFF81C784), // Light Green
              Color(0xFFFFB74D), // Light Orange
              Color(0xFFBA68C8), // Light Purple
              Color(0xFF4DB6AC), // Light Teal
              Color(0xFFF06292), // Light Pink
              Color(0xFF7986CB), // Light Indigo
              Color(0xFFFFD54F), // Light Amber
              Color(0xFF4DD0E1), // Light Cyan
            ]
          : [
              Color(0xFF1976D2), // Dark Blue
              Color(0xFFD32F2F), // Dark Red
              Color(0xFF388E3C), // Dark Green
              Color(0xFFF57C00), // Dark Orange
              Color(0xFF7B1FA2), // Dark Purple
              Color(0xFF00695C), // Dark Teal
              Color(0xFFC2185B), // Dark Pink
              Color(0xFF303F9F), // Dark Indigo
              Color(0xFFF57F17), // Dark Amber
              Color(0xFF0097A7), // Dark Cyan
            ];

      return groupedEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final description = item['_description'] ?? 'Untitled';
        final durationString = item['_duration'] as String;
        final durationInMinutes = _parseDurationToMinutes(durationString);
        final percentage =
            totalMinutes > 0 ? (durationInMinutes / totalMinutes) * 100 : 0.0;

        return PieChartData(
          description: description,
          durationInMinutes: durationInMinutes,
          percentage: percentage,
          color: colors[index % colors.length],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  List<BarChartData> _prepareBarChartData() {
    if (categoryAnalyticsData == null) return [];

    try {
      final dailyStats =
          categoryAnalyticsData!['daily_stats'] as Map<String, dynamic>;
      return dailyStats.entries.map((entry) {
        final date = entry.key;
        final durationString = entry.value as String;
        final durationInMinutes =
            _parseDurationToMinutes(durationString).toInt();

        return BarChartData(
          date: date,
          durationInMinutes: durationInMinutes,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  List<TimeEntry> _prepareTimeEntries() {
    if (categoryAnalyticsData == null) return [];

    try {
      final timeEntries = categoryAnalyticsData!['time_entries'] as List;
      return timeEntries
          .map((entry) {
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
      return [];
    }
  }

  double _parseDurationToMinutes(String duration) {
    try {
      final parts = duration.split(':');
      if (parts.length >= 3) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final secondsPart = parts[2].split('.')[0];
        final seconds = int.tryParse(secondsPart) ?? 0;
        return (hours * 60) + minutes + (seconds / 60);
      }
    } catch (e) {}
    return 0.0;
  }

  String _formatDurationString(String duration) {
    try {
      final parts = duration.split(':');
      if (parts.length >= 3) {
        final hours = parts[0];
        final minutes = parts[1];
        final secondsPart = parts[2].split('.')[0];
        return '$hours:$minutes:$secondsPart';
      }
    } catch (e) {}
    return duration;
  }
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
  final int durationInMinutes;
}
