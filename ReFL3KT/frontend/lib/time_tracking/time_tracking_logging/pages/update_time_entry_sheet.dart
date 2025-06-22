import 'package:flutter/material.dart';
import 'package:frontend/api_methods/fetch_time_entries.dart';
import 'package:frontend/api_methods/post_time_entry.dart';
import 'package:frontend/api_methods/update_time_entry.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/timelog_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/time_tracking/Methods/pick_date_time.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/category_picker.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:provider/provider.dart';

class UpdateTimeEntrySheet extends StatefulWidget {
  UpdateTimeEntrySheet({super.key, required this.timeEntry});
  TimeEntry timeEntry;

  @override
  State<UpdateTimeEntrySheet> createState() => _TimeEntrySheetState();
}

class _TimeEntrySheetState extends State<UpdateTimeEntrySheet>
    with TickerProviderStateMixin {
  late DateTime newStartTime;
  late DateTime newEndTime;
  late String desc;
  late TextEditingController descriptionController;
  late int selectedCategoryId;
  late String selectedCategoryName;
  late DateTime originalDate;
  bool isLoading = false;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    newStartTime = widget.timeEntry.startTime;
    newEndTime = widget.timeEntry.endTime ?? DateTime.now();
    desc = widget.timeEntry.description;
    descriptionController = TextEditingController(text: desc);
    selectedCategoryId = widget.timeEntry.categoryId ?? -1;
    selectedCategoryName = widget.timeEntry.categoryName ?? 'Uncategorized';
    originalDate = DateTime(
      widget.timeEntry.startTime.year,
      widget.timeEntry.startTime.month,
      widget.timeEntry.startTime.day,
    );

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Widget buildGrabHandle(bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 50,
      height: 5,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  void _showDateValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('End time must be after start time')),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required Widget child,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required bool isDarkMode,
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[700]?.withOpacity(0.4) ?? Colors.transparent
              : Colors.grey[300]?.withOpacity(0.8) ?? Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.1)
                : Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        elevation: onPressed != null ? 1 : 0,
        shadowColor: Colors.black.withOpacity(0.05),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String title,
    required DateTime time,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
    required Color cardColor,
    required Color textColor,
    required Color hintColor,
    required Color accentColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[700]?.withOpacity(0.3) ?? Colors.transparent
              : Colors.grey[200]?.withOpacity(0.8) ?? Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: hintColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time.toLocal().toString().substring(0, 16),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: hintColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final scaffoldColor = isDarkMode ? scaffoldColorDark : scaffoldColorLight;
    final cardColor =
        isDarkMode ? timeEntryWidgetColorDark : timeEntryWidgetColorLight;
    final textColor = isDarkMode
        ? timeEntryWidgetTextColorDark
        : timeEntryWidgetTextColorLight;
    final borderColor = isDarkMode ? borderColorDark : borderColorLight;
    final accentColor =
        isDarkMode ? primaryAccentColorDark : primaryAccentColorLight;
    final hintColor =
        isDarkMode ? secondaryAccentColorDark : secondaryAccentColorLight;

    final duration = newEndTime.difference(newStartTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final isValidDuration = duration.inMinutes > 0;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scaffoldColor,
                  scaffoldColor.withOpacity(0.95),
                ],
              ),
            ),
            width: double.infinity,
            child: Column(
              children: [
                // Header with grab handle
                buildGrabHandle(isDarkMode),

                // Top bar with close, title, and save
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildAnimatedButton(
                        onPressed:
                            isLoading ? null : () => Navigator.pop(context),
                        backgroundColor: cardColor,
                        isDarkMode: isDarkMode,
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.close,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Edit Time Entry',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      _buildAnimatedButton(
                        onPressed: (isLoading || !isValidDuration)
                            ? null
                            : () async {
                                if (descriptionController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error,
                                              color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Please add a description'),
                                        ],
                                      ),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  );
                                  return;
                                }

                                setState(() => isLoading = true);

                                final timelogProvider =
                                    Provider.of<TimelogProvider>(context,
                                        listen: false);

                                // Store original values for comparison
                                final originalStartTime =
                                    widget.timeEntry.startTime;
                                final originalEndTime =
                                    widget.timeEntry.endTime;
                                final originalDescription =
                                    widget.timeEntry.description;
                                final originalCategoryId =
                                    widget.timeEntry.categoryId;
                                final originalCategoryName =
                                    widget.timeEntry.categoryName;

                                // Update the time entry object
                                widget.timeEntry.description =
                                    descriptionController.text.trim();
                                widget.timeEntry.startTime = newStartTime;
                                widget.timeEntry.endTime = newEndTime;
                                widget.timeEntry.categoryId =
                                    selectedCategoryId;
                                widget.timeEntry.categoryName =
                                    selectedCategoryName;

                                try {
                                  final updatedEntry = await updateTimeEntry(
                                      widget.timeEntry,
                                      Provider.of<UserProvider>(context,
                                              listen: false)
                                          .userId!);

                                  if (updatedEntry != null) {
                                    final newDate = DateTime(newStartTime.year,
                                        newStartTime.month, newStartTime.day);
                                    final oldDate = DateTime(
                                        originalStartTime.year,
                                        originalStartTime.month,
                                        originalStartTime.day);

                                    if (newDate != oldDate) {
                                      if (timelogProvider.map
                                          .containsKey(oldDate)) {
                                        timelogProvider.map[oldDate]
                                            ?.removeWhere((entry) =>
                                                entry.timeEntryId ==
                                                    widget.timeEntry
                                                        .timeEntryId ||
                                                (entry.startTime ==
                                                        originalStartTime &&
                                                    entry.endTime ==
                                                        originalEndTime &&
                                                    entry.description ==
                                                        originalDescription));

                                        if (timelogProvider
                                                .map[oldDate]?.isEmpty ==
                                            true) {
                                          timelogProvider.map.remove(oldDate);
                                        }
                                      }
                                      timelogProvider.addTimeEntry(
                                          newDate, widget.timeEntry);
                                    } else {
                                      timelogProvider.sort();
                                      timelogProvider.notifyListeners();
                                    }

                                    if (!mounted) return;
                                    Navigator.pop(context);

                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.white),
                                            SizedBox(width: 8),
                                            Text(
                                                'Time entry updated successfully'),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    );
                                  } else {
                                    throw Exception('Failed to update entry');
                                  }
                                } catch (e) {
                                  // Revert changes if API call failed
                                  widget.timeEntry.description =
                                      originalDescription;
                                  widget.timeEntry.startTime =
                                      originalStartTime;
                                  widget.timeEntry.endTime = originalEndTime;
                                  widget.timeEntry.categoryId =
                                      originalCategoryId;
                                  widget.timeEntry.categoryName =
                                      originalCategoryName;

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error,
                                              color: Colors.white),
                                          SizedBox(width: 8),
                                          Expanded(
                                              child: Text(
                                                  'Failed to update time entry')),
                                        ],
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => isLoading = false);
                                  }
                                }
                              },
                        backgroundColor: cardColor,
                        isDarkMode: isDarkMode,
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      accentColor),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save,
                                      color: isValidDuration
                                          ? accentColor
                                          : hintColor,
                                      size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    'Save',
                                    style: TextStyle(
                                      color: isValidDuration
                                          ? textColor
                                          : hintColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description field
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode
                                      ? Colors.black.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.grey[700]?.withOpacity(0.3) ??
                                        Colors.transparent
                                    : Colors.grey[200]?.withOpacity(0.8) ??
                                        Colors.transparent,
                                width: 1.2,
                              ),
                            ),
                            child: TextField(
                              controller: descriptionController,
                              cursorColor: accentColor,
                              style: TextStyle(color: textColor, fontSize: 16),
                              enabled: !isLoading,
                              maxLines: 3,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                hintText: "What did you work on?",
                                hintStyle: TextStyle(color: hintColor),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(Icons.description_outlined,
                                      color: accentColor),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: accentColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              onChanged: (value) => desc = value,
                            ),
                          ),

                          // Category picker
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: CategoryPicker(
                              initialCategoryName: selectedCategoryName,
                              onCategorySelected: (cat) {
                                setState(() {
                                  if (cat != null) {
                                    selectedCategoryId = cat.categoryId;
                                    selectedCategoryName = cat.name;
                                  } else {
                                    selectedCategoryId = -1;
                                    selectedCategoryName = 'Uncategorized';
                                  }
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Time selectors
                          _buildTimeSelector(
                            title: 'Start Time',
                            time: newStartTime,
                            icon: Icons.play_arrow,
                            onTap: () async {
                              final picked =
                                  await pickDateTime(newStartTime, context);
                              if (picked.isAfter(newEndTime)) {
                                _showDateValidationError();
                                return;
                              }
                              setState(() => newStartTime = picked);
                            },
                            isDarkMode: isDarkMode,
                            cardColor: cardColor,
                            textColor: textColor,
                            hintColor: hintColor,
                            accentColor: accentColor,
                          ),

                          _buildTimeSelector(
                            title: 'End Time',
                            time: newEndTime,
                            icon: Icons.pause,
                            onTap: () async {
                              final picked =
                                  await pickDateTime(newEndTime, context);
                              if (picked.isBefore(newStartTime) ||
                                  picked.isAtSameMomentAs(newStartTime)) {
                                _showDateValidationError();
                                return;
                              }
                              setState(() => newEndTime = picked);
                            },
                            isDarkMode: isDarkMode,
                            cardColor: cardColor,
                            textColor: textColor,
                            hintColor: hintColor,
                            accentColor: accentColor,
                          ),

                          // Duration display
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isValidDuration
                                    ? [
                                        accentColor.withOpacity(0.12),
                                        accentColor.withOpacity(0.06),
                                      ]
                                    : [
                                        Colors.red.withOpacity(0.12),
                                        Colors.red.withOpacity(0.06),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isValidDuration
                                    ? accentColor.withOpacity(0.3)
                                    : Colors.red.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isValidDuration
                                        ? accentColor.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isValidDuration
                                        ? Icons.access_time
                                        : Icons.error,
                                    color: isValidDuration
                                        ? accentColor
                                        : Colors.red,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Duration',
                                        style: TextStyle(
                                          color: hintColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isValidDuration
                                            ? '${hours}h ${minutes}m'
                                            : 'Invalid duration',
                                        style: TextStyle(
                                          color: isValidDuration
                                              ? textColor
                                              : Colors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
