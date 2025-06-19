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

    siblingSeparation = 400;
    subtreeSeparation = 400;
    levelSeparation = 400;
    GOAL_WIDGET_HEIGHT = 100;
    GOAL_WIDGET_WIDTH = 200;
    edgeStrokeWidth = 20;
  } else if (Platform.isAndroid || Platform.isIOS) {
    siblingSeparation = 200;
    subtreeSeparation = 200;
    levelSeparation = 200;
    GOAL_WIDGET_HEIGHT = 50;
    GOAL_WIDGET_WIDTH = 150;
    edgeStrokeWidth = 10;
  } else {
    siblingSeparation = 600;
    subtreeSeparation = 700;
    levelSeparation = 300;
    GOAL_WIDGET_HEIGHT = 60;
    GOAL_WIDGET_WIDTH = 100;
    edgeStrokeWidth = 10;
  }
  if (Platform.isAndroid || Platform.isIOS) {
    siblingSeparation = 200;
    subtreeSeparation = 200;
    levelSeparation = 200;
    GOAL_WIDGET_HEIGHT = 50;
    GOAL_WIDGET_WIDTH = 150;
    edgeStrokeWidth = 10;
  }
}
