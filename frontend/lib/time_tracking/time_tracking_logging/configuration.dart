import 'package:flutter/material.dart';

// Clean black and white theme
// Color scaffoldColor = Color(0xff0A0A0A); // Pure black background

// time_entry_widget
const double timeEntryWidgetPadding = 4;
BorderRadius timeEntryWidgetBorderRadius =
    BorderRadius.circular(8); // Clean rounded corners
Color timeEntryWidgetBorderColor = Color(0xff333333); // Dark gray border
Color timeEntryWidgetColor = Color(0xff1A1A1A); // Dark charcoal cards
double timeEntryWidgetWidthMultiplier = .95;
double timeEntryWidgetHeightMultiplier = .08;
const double timeEntryWidgetTextPadding = 8;
FontWeight timeEntryWidgetFontweight = FontWeight.w600;
double timeEntryWidgetFontSize = 0.015;
double timeEntryWidgetCategoryFontSize = timeEntryWidgetFontSize;
double timeEntryWidgetDescriptionFontSize = timeEntryWidgetFontSize;
double timeEntryWidgetDurationFontSize = timeEntryWidgetFontSize;
Color timeEntryWidgetTextColor = Color(0xffF5F5F5); // Off-white text
double timeEntryWidgetIconSize = timeEntryWidgetFontSize * 2;

// day_timeline_widget
const double dayTimelineWidgetPadding = 8.0;
double dayTimelineWidgetDateFontSize = 0.02;
FontWeight dayTimelineWidgetDateFontWeight = FontWeight.bold;
Color dayTimelineWidgetDateColor = Color(0xffFFFFFF); // Pure white for dates
CrossAxisAlignment dayTimelineWidgetCrossAxisAlignment =
    CrossAxisAlignment.start;

// timeline_widget
ScrollPhysics timelineWidgetScrollPhysics = AlwaysScrollableScrollPhysics();
bool timelineWidgetShrinkWrap = false;

// Monochrome accent colors for highlights and states
Color primaryAccentColor = Color(0xffFFFFFF); // Pure white
Color secondaryAccentColor = Color(0xffB8B8B8); // Light gray
Color subtleAccentColor = Color(0xff666666); // Medium gray
Color borderColor = Color(0xff333333); // Dark gray for borders
