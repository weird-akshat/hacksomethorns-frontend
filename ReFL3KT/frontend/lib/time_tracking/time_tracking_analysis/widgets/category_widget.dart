import 'package:flutter/material.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:provider/provider.dart';
import 'package:frontend/time_tracking/entities/category.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/category_detailed_analytics.dart';
// import 'package:frontend/config/theme_config.dart'; // Your config file

class CategoryWidget extends StatelessWidget {
  final Category category;

  const CategoryWidget({
    required this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Get colors based on current theme
        final isDark = themeProvider.isDarkMode;
        final cardColor =
            isDark ? timeEntryWidgetColorDark : timeEntryWidgetColorLight;
        final textColor = isDark
            ? timeEntryWidgetTextColorDark
            : timeEntryWidgetTextColorLight;
        final borderColor = isDark
            ? timeEntryWidgetBorderColorDark
            : timeEntryWidgetBorderColorLight;
        final accentColor =
            isDark ? primaryAccentColorDark : primaryAccentColorLight;
        final subtleColor =
            isDark ? subtleAccentColorDark : subtleAccentColorLight;

        return Container(
          margin: EdgeInsets.symmetric(
            vertical: timeEntryWidgetPadding * 2,
            horizontal: timeEntryWidgetPadding * 2,
          ),
          padding: EdgeInsets.all(timeEntryWidgetTextPadding * 2.25),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: timeEntryWidgetBorderRadius,
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            // Subtle shadow for depth
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          height: MediaQuery.of(context).size.height *
              timeEntryWidgetHeightMultiplier *
              1.25,
          width: MediaQuery.of(context).size.width *
              timeEntryWidgetWidthMultiplier,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category indicator dot with subtle glow
              Container(
                width: timeEntryWidgetIconSize * 0.8,
                height: timeEntryWidgetIconSize * 0.8,
                margin: EdgeInsets.only(right: timeEntryWidgetTextPadding * 2),
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              // Category name
              Expanded(
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width *
                        timeEntryWidgetFontSize *
                        3,
                    fontWeight: timeEntryWidgetFontweight,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Subtle chevron indicator
              Icon(
                Icons.chevron_right_rounded,
                color: subtleColor,
                size: timeEntryWidgetIconSize * 1.2,
              ),
            ],
          ),
        );
      },
    );
  }
}
