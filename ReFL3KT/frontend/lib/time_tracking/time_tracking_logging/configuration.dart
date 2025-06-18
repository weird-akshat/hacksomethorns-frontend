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

// DARK MODE COLORS (your original theme)
Color scaffoldColorDark = Color(0xff0A0A0A); // Pure black background
Color timeEntryWidgetBorderColorDark = Color(0xff333333); // Dark gray border
Color timeEntryWidgetColorDark = Color(0xff1A1A1A); // Dark charcoal cards
Color timeEntryWidgetTextColorDark = Color(0xffF5F5F5); // Off-white text
Color dayTimelineWidgetDateColorDark =
    Color(0xffFFFFFF); // Pure white for dates
Color primaryAccentColorDark = Color(0xffFFFFFF); // Pure white
Color secondaryAccentColorDark = Color(0xffB8B8B8); // Light gray
Color subtleAccentColorDark = Color(0xff666666); // Medium gray
Color borderColorDark = Color(0xff333333); // Dark gray for borders

// LIGHT MODE COLORS
Color scaffoldColorLight = Color(0xffFFFFFF); // Pure white background
Color timeEntryWidgetBorderColorLight = Color(0xffE0E0E0); // Light gray border
Color timeEntryWidgetColorLight = Color(0xffF8F8F8); // Light gray cards
Color timeEntryWidgetTextColorLight = Color(0xff1A1A1A); // Dark text
Color dayTimelineWidgetDateColorLight =
    Color(0xff000000); // Pure black for dates
Color primaryAccentColorLight = Color(0xff000000); // Pure black
Color secondaryAccentColorLight = Color(0xff555555); // Dark gray
Color subtleAccentColorLight = Color(0xffAAAAAA); // Medium gray
Color borderColorLight = Color(0xffE0E0E0); // Light gray for borders

// time_entry_widget (non-color properties remain the same)
// const double timeEntryWidgetPadding = 4;
// BorderRadius timeEntryWidgetBorderRadius = BorderRadius.circular(8); // Clean rounded corners
// double timeEntryWidgetWidthMultiplier = .95;
// double timeEntryWidgetHeightMultiplier = .08;
// const double timeEntryWidgetTextPadding = 8;
// FontWeight timeEntryWidgetFontweight = FontWeight.w600;
// double timeEntryWidgetFontSize = 0.015;
// double timeEntryWidgetCategoryFontSize = timeEntryWidgetFontSize;
// double timeEntryWidgetDescriptionFontSize = timeEntryWidgetFontSize;
// double timeEntryWidgetDurationFontSize = timeEntryWidgetFontSize;
// double timeEntryWidgetIconSize = timeEntryWidgetFontSize * 2;

// day_timeline_widget (non-color properties remain the same)
// const double dayTimelineWidgetPadding = 8.0;
// double dayTimelineWidgetDateFontSize = 0.02;
// FontWeight dayTimelineWidgetDateFontWeight = FontWeight.bold;
// CrossAxisAlignment dayTimelineWidgetCrossAxisAlignment = CrossAxisAlignment.start;

// timeline_widget (non-color properties remain the same)
// ScrollPhysics timelineWidgetScrollPhysics = AlwaysScrollableScrollPhysics();
// bool timelineWidgetShrinkWrap = false;
