import 'package:flutter/material.dart';

class DayTimelineWidget extends StatelessWidget {
  const DayTimelineWidget({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListView.builder(
        itemCount: 1, itemBuilder: (context, index) => Text('data'));
  }
}
