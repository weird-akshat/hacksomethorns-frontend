import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

late double stackWidth;
late double stackHeight;
late double siblingSeparation;
late double subtreeSeparation;
late double levelSeparation;
late double GOAL_WIDGET_HEIGHT;
late double edgeStrokeWidth;
late double GOAL_WIDGET_WIDTH;

bool _isConfigInitialized = false;

void initConfig() {
  if (_isConfigInitialized) return;
  _isConfigInitialized = true;

  if (kIsWeb) {
    // Web-specific config
    siblingSeparation = 300;
    subtreeSeparation = 350;
    levelSeparation = 280;
    GOAL_WIDGET_HEIGHT = 120;
    GOAL_WIDGET_WIDTH = 220;
    edgeStrokeWidth = 3;
  } else if (Platform.isAndroid || Platform.isIOS) {
    // Mobile-optimized config
    siblingSeparation = 40;
    subtreeSeparation = 180;
    levelSeparation = 180;
    GOAL_WIDGET_HEIGHT = 80;
    GOAL_WIDGET_WIDTH = 140;
    edgeStrokeWidth = 1.25;
  } else {
    // Desktop config
    siblingSeparation = 400;
    subtreeSeparation = 450;
    levelSeparation = 200;
    GOAL_WIDGET_HEIGHT = 100;
    GOAL_WIDGET_WIDTH = 180;
    edgeStrokeWidth = 3;
  }
}
