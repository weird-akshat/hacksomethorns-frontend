import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/api_methods/post_time_entry.dart';
import 'package:frontend/api_methods/update_time_entry.dart';
import 'package:frontend/providers/current_time_entry_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/timelog_provider.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:provider/provider.dart';

class CurrentTimeTrackingWidget extends StatefulWidget {
  const CurrentTimeTrackingWidget({
    super.key,
    required this.themeProvider,
    required this.userId,
  });

  final ThemeProvider themeProvider;
  final String userId;

  @override
  State<CurrentTimeTrackingWidget> createState() =>
      _CurrentTimeTrackingWidgetState();
}

class _CurrentTimeTrackingWidgetState extends State<CurrentTimeTrackingWidget> {
  late TimeEntry? timeEntry;
  bool isTracking = false;
  bool isLoading = false; // Add loading state
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadEntry();
    _startPeriodicUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      final provider = context.read<CurrentTimeEntryProvider>();
      if (provider.isTracking && provider.currentEntry != null) {
        setState(() {});
      }
    });
  }

  Future<void> _loadEntry() async {
    final provider =
        Provider.of<CurrentTimeEntryProvider>(context, listen: false);
    await provider.loadCurrentEntry(widget.userId);

    setState(() {
      timeEntry = provider.currentEntry;
      isTracking = provider.isTracking;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeProvider.isDarkMode;
    final textColor =
        isDark ? timeEntryWidgetTextColorDark : timeEntryWidgetTextColorLight;

    return Consumer<CurrentTimeEntryProvider>(
      builder: (context, provider, _) {
        final timeEntry = provider.currentEntry;
        final isTracking = provider.isTracking;

        final textColor = widget.themeProvider.isDarkMode
            ? timeEntryWidgetTextColorDark
            : timeEntryWidgetTextColorLight;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: MediaQuery.of(context).size.height * 0.13,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.themeProvider.isDarkMode
                ? Colors.grey[900]
                : Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.themeProvider.isDarkMode
                    ? Colors.black26
                    : Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: isTracking && timeEntry != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "⏱ ${_formatDuration(DateTime.now().difference(timeEntry.startTime))}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("📋 ${timeEntry.description}",
                              style: TextStyle(fontSize: 14, color: textColor)),
                          const SizedBox(height: 4),
                          Text("🏷 ${timeEntry.categoryName}",
                              style: TextStyle(fontSize: 14, color: textColor)),
                        ],
                      )
                    : Center(
                        child: Text("No active timer",
                            style: TextStyle(fontSize: 14, color: textColor))),
              ),
              if (isTracking && timeEntry != null)
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true; // Set loading to true
                          });

                          try {
                            final currentProvider =
                                Provider.of<CurrentTimeEntryProvider>(context,
                                    listen: false);
                            final timeLogProvider =
                                Provider.of<TimelogProvider>(context,
                                    listen: false);

                            final now = DateTime.now();
                            timeEntry.endTime = now;

                            timeLogProvider.addTimeEntry(now, timeEntry);
                            timeLogProvider.sort();

                            await updateTimeEntry(timeEntry);
                            currentProvider.clearEntry();
                          } catch (e) {
                            // Handle error if needed
                            print('Error updating time entry: $e');
                          } finally {
                            if (mounted) {
                              setState(() {
                                isLoading = false; // Set loading to false
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    backgroundColor: widget.themeProvider.isDarkMode
                        ? Colors.blueGrey[700]
                        : Colors.blue,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.pause, color: Colors.white, size: 28),
                )
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
