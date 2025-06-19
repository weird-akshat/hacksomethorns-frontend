import 'package:flutter/material.dart';
import 'package:frontend/api_methods/api_service_analytics.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class AnalyticsScreen extends StatefulWidget {
  final bool darkMode;
  const AnalyticsScreen({super.key, this.darkMode = false});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> generateMonochromeColors(int count) {
    List<Color> colors = [];
    for (int i = 0; i < count; i++) {
      double hue = (360.0 * i / count) % 360;
      HSLColor hsl = HSLColor.fromAHSL(1.0, hue, 0.6, 0.6);
      colors.add(hsl.toColor());
    }
    return colors;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // Black and white color scheme
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF212121);
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder(
        future: Future.wait([
          ApiServiceAnalytics.getCategoryTimeSpentMap("1"),
          ApiServiceAnalytics.getCategoryPercentageMap("1"),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.white : Colors.black,
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: subtitleColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load analytics',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final Map<String, String> timeSpentMap = Map<String, String>.from(
            snapshot.data![0],
          );
          final Map<String, double> percentageMap = Map<String, double>.from(
            snapshot.data![1],
          );

          if (timeSpentMap.isEmpty || percentageMap.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: subtitleColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start using the app to see analytics',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Create sorted data for the chart and list
          List<ChartData> chartData = [];
          timeSpentMap.forEach((category, time) {
            final percent = percentageMap[category];
            if (percent != null) {
              chartData.add(ChartData(
                category,
                double.parse(percent.toStringAsFixed(1)),
                time,
              ));
            }
          });

          // Sort by percentage (descending)
          chartData.sort((a, b) => b.y.compareTo(a.y));

          // Generate monochrome colors
          final colorList = generateMonochromeColors(chartData.length);
          for (int i = 0; i < chartData.length; i++) {
            chartData[i].color = colorList[i];
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Column(
                children: [
                  // Pie Chart Card
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'Time Distribution',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SfCircularChart(
                                margin: const EdgeInsets.all(0),
                                series: <CircularSeries>[
                                  DoughnutSeries<ChartData, String>(
                                    dataSource: chartData,
                                    pointColorMapper: (ChartData data, _) =>
                                        data.color,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                      textStyle: TextStyle(
                                        color: textColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      labelIntersectAction:
                                          LabelIntersectAction.shift,
                                    ),
                                    dataLabelMapper: (ChartData data, _) =>
                                        '${data.y}%',
                                    radius: '80%',
                                    strokeColor: backgroundColor,
                                    strokeWidth: 2,
                                  ),
                                ],
                                tooltipBehavior: TooltipBehavior(
                                  enable: true,
                                  format: 'point.x: point.y%',
                                  textStyle: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header for the list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Text(
                          'Detailed Breakdown',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${chartData.length} categories',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List of categories
                  Expanded(
                    child: ListView.builder(
                      itemCount: chartData.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final data = chartData[index];
                        final formattedTime = data.time.split('.').first;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[200]!,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.08),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Color indicator with rank
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: data.color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: backgroundColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color:
                                          data.color!.computeLuminance() > 0.5
                                              ? Colors.black
                                              : Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),

                              // Category name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.x,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                        color: subtitleColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Percentage
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${data.y}%",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.time, [this.color]);
  final String x;
  final double y;
  final String time;
  Color? color;
}
