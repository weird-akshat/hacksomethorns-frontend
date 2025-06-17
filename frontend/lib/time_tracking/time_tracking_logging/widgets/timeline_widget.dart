import 'package:flutter/material.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/day_timeline_widget.dart';
import 'package:provider/provider.dart';
// import 'package:frontend/time_tracking/pages/configuration.dart';

class TimelineWidget extends StatelessWidget {
  TimelineWidget({super.key});

  final map = {
    // Day 0 (Today)
    DateTime.now(): [
      TimeEntry(
          description: 'Morning standup meeting',
          timeEntryId: 'entry1',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(hours: 8)),
          endTime:
              DateTime.now().subtract(const Duration(hours: 7, minutes: 30)),
          categoryId: 1,
          categoryName: 'Meetings'),
      TimeEntry(
          description: 'Code review - PR #234',
          timeEntryId: 'entry2',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(hours: 7, minutes: 30)),
          endTime:
              DateTime.now().subtract(const Duration(hours: 6, minutes: 45)),
          categoryId: 2,
          categoryName: 'Code Review'),
      TimeEntry(
          description: 'Implemented user authentication',
          timeEntryId: 'entry3',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(hours: 6, minutes: 45)),
          endTime:
              DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
          categoryId: 3,
          categoryName: 'Development'),
      TimeEntry(
          description: 'Fixed login validation bug',
          timeEntryId: 'entry4',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
          endTime: DateTime.now().subtract(const Duration(hours: 5)),
          categoryId: 4,
          categoryName: 'Bug Fix'),
      TimeEntry(
          description: 'Database schema updates',
          timeEntryId: 'entry5',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(hours: 5)),
          endTime:
              DateTime.now().subtract(const Duration(hours: 4, minutes: 15)),
          categoryId: 5,
          categoryName: 'Database'),
      TimeEntry(
          description: 'UI design for dashboard',
          timeEntryId: 'entry6',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(hours: 4, minutes: 15)),
          endTime:
              DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
          categoryId: 6,
          categoryName: 'UI Design'),
      TimeEntry(
          description: 'Testing new API endpoints',
          timeEntryId: 'entry7',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
          endTime: DateTime.now().subtract(const Duration(hours: 3)),
          categoryId: 7,
          categoryName: 'Testing'),
      TimeEntry(
          description: 'Documentation update',
          timeEntryId: 'entry8',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(hours: 3)),
          endTime:
              DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
          categoryId: 8,
          categoryName: 'Documentation'),
      TimeEntry(
          description: 'Performance optimization',
          timeEntryId: 'entry9',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
          endTime:
              DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
          categoryId: 9,
          categoryName: 'Optimization'),
      TimeEntry(
          description: 'Security audit review',
          timeEntryId: 'entry10',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
          endTime: DateTime.now().subtract(const Duration(hours: 2)),
          categoryId: 10,
          categoryName: 'Security'),
      TimeEntry(
          description: 'Team sync meeting',
          timeEntryId: 'entry11',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          categoryId: 1,
          categoryName: 'Meetings'),
      TimeEntry(
          description: 'API integration testing',
          timeEntryId: 'entry12',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          endTime:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
          categoryId: 7,
          categoryName: 'Testing'),
      TimeEntry(
          description: 'Mobile app debugging',
          timeEntryId: 'entry13',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
          endTime: DateTime.now().subtract(const Duration(hours: 1)),
          categoryId: 4,
          categoryName: 'Bug Fix'),
      TimeEntry(
          description: 'Responsive design fixes',
          timeEntryId: 'entry14',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now().subtract(const Duration(minutes: 45)),
          categoryId: 6,
          categoryName: 'UI Design'),
      TimeEntry(
          description: 'Client demo preparation',
          timeEntryId: 'entry15',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(minutes: 45)),
          endTime: DateTime.now().subtract(const Duration(minutes: 30)),
          categoryId: 11,
          categoryName: 'Client Work'),
      TimeEntry(
          description: 'Sprint planning meeting',
          timeEntryId: 'entry16',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(minutes: 30)),
          endTime: DateTime.now().subtract(const Duration(minutes: 15)),
          categoryId: 1,
          categoryName: 'Meetings'),
      TimeEntry(
          description: 'Code refactoring',
          timeEntryId: 'entry17',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(minutes: 15)),
          endTime: DateTime.now().subtract(const Duration(minutes: 10)),
          categoryId: 3,
          categoryName: 'Development'),
      TimeEntry(
          description: 'Email responses',
          timeEntryId: 'entry18',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(minutes: 10)),
          endTime: DateTime.now().subtract(const Duration(minutes: 5)),
          categoryId: 12,
          categoryName: 'Communication'),
      TimeEntry(
          description: 'Task planning',
          timeEntryId: 'entry19',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(minutes: 5)),
          endTime: DateTime.now().subtract(const Duration(minutes: 2)),
          categoryId: 13,
          categoryName: 'Planning'),
      TimeEntry(
          description: 'Status update',
          timeEntryId: 'entry20',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(minutes: 2)),
          endTime: DateTime.now(),
          categoryId: 12,
          categoryName: 'Communication'),
    ],

    // Day 1 (Yesterday)
    DateTime.now().subtract(const Duration(days: 1)): [
      TimeEntry(
          description: 'Morning coffee and email check',
          timeEntryId: 'entry21',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 7, minutes: 45)),
          categoryId: 12,
          categoryName: 'Communication'),
      TimeEntry(
          description: 'Feature development - user profiles',
          timeEntryId: 'entry22',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 7, minutes: 45)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 6, minutes: 30)),
          categoryId: 3,
          categoryName: 'Development'),
      TimeEntry(
          description: 'Unit test writing',
          timeEntryId: 'entry23',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 6, minutes: 30)),
          endTime: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
          categoryId: 7,
          categoryName: 'Testing'),
      TimeEntry(
          description: 'Bug investigation - payment flow',
          timeEntryId: 'entry24',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 5, minutes: 15)),
          categoryId: 4,
          categoryName: 'Bug Fix'),
      TimeEntry(
          description: 'Database migration script',
          timeEntryId: 'entry25',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 5, minutes: 15)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 4, minutes: 45)),
          categoryId: 5,
          categoryName: 'Database'),
      TimeEntry(
          description: 'UI mockup review',
          timeEntryId: 'entry26',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 4, minutes: 45)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 4, minutes: 15)),
          categoryId: 6,
          categoryName: 'UI Design'),
      TimeEntry(
          description: 'Integration testing',
          timeEntryId: 'entry27',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 4, minutes: 15)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 3, minutes: 45)),
          categoryId: 7,
          categoryName: 'Testing'),
      TimeEntry(
          description: 'Technical documentation',
          timeEntryId: 'entry28',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 3, minutes: 45)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 3, minutes: 15)),
          categoryId: 8,
          categoryName: 'Documentation'),
      TimeEntry(
          description: 'Code optimization',
          timeEntryId: 'entry29',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 3, minutes: 15)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 2, minutes: 45)),
          categoryId: 9,
          categoryName: 'Optimization'),
      TimeEntry(
          description: 'Security vulnerability fix',
          timeEntryId: 'entry30',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 2, minutes: 45)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 2, minutes: 30)),
          categoryId: 10,
          categoryName: 'Security'),
      TimeEntry(
          description: 'Client call - requirements',
          timeEntryId: 'entry31',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 2, minutes: 30)),
          endTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          categoryId: 11,
          categoryName: 'Client Work'),
      TimeEntry(
          description: 'API documentation update',
          timeEntryId: 'entry32',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 1, minutes: 45)),
          categoryId: 8,
          categoryName: 'Documentation'),
      TimeEntry(
          description: 'Frontend bug fixes',
          timeEntryId: 'entry33',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 1, minutes: 45)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 1, minutes: 15)),
          categoryId: 4,
          categoryName: 'Bug Fix'),
      TimeEntry(
          description: 'UI component styling',
          timeEntryId: 'entry34',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 1, minutes: 15)),
          endTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
          categoryId: 6,
          categoryName: 'UI Design'),
      TimeEntry(
          description: 'Project milestone review',
          timeEntryId: 'entry35',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
          endTime:
              DateTime.now().subtract(const Duration(days: 1, minutes: 45)),
          categoryId: 13,
          categoryName: 'Planning'),
      TimeEntry(
          description: 'Team retrospective',
          timeEntryId: 'entry36',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 1, minutes: 45)),
          endTime:
              DateTime.now().subtract(const Duration(days: 1, minutes: 30)),
          categoryId: 1,
          categoryName: 'Meetings'),
      TimeEntry(
          description: 'New feature implementation',
          timeEntryId: 'entry37',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 1, minutes: 30)),
          endTime:
              DateTime.now().subtract(const Duration(days: 1, minutes: 15)),
          categoryId: 3,
          categoryName: 'Development'),
      TimeEntry(
          description: 'Slack team updates',
          timeEntryId: 'entry38',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 1, minutes: 15)),
          endTime:
              DateTime.now().subtract(const Duration(days: 1, minutes: 10)),
          categoryId: 12,
          categoryName: 'Communication'),
      TimeEntry(
          description: 'Tomorrow task planning',
          timeEntryId: 'entry39',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 1, minutes: 10)),
          endTime: DateTime.now().subtract(const Duration(days: 1, minutes: 5)),
          categoryId: 13,
          categoryName: 'Planning'),
      TimeEntry(
          description: 'End of day wrap-up',
          timeEntryId: 'entry40',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 1, minutes: 5)),
          endTime: DateTime.now().subtract(const Duration(days: 1)),
          categoryId: 12,
          categoryName: 'Communication'),
    ],

    // Day 2 (2 days ago)
    DateTime.now().subtract(const Duration(days: 2)): [
      TimeEntry(
          description: 'Early morning code review',
          timeEntryId: 'entry41',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 7, minutes: 30)),
          categoryId: 2,
          categoryName: 'Code Review'),
      TimeEntry(
          description: 'Backend API development',
          timeEntryId: 'entry42',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 7, minutes: 30)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 6, minutes: 45)),
          categoryId: 3,
          categoryName: 'Development'),
      TimeEntry(
          description: 'Database query optimization',
          timeEntryId: 'entry43',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 6, minutes: 45)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 6, minutes: 15)),
          categoryId: 5,
          categoryName: 'Database'),
      TimeEntry(
          description: 'Critical bug fix deployment',
          timeEntryId: 'entry44',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 6, minutes: 15)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 5, minutes: 45)),
          categoryId: 4,
          categoryName: 'Bug Fix'),
      TimeEntry(
          description: 'Mobile app testing',
          timeEntryId: 'entry45',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 5, minutes: 45)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 5, minutes: 15)),
          categoryId: 7,
          categoryName: 'Testing'),
      TimeEntry(
          description: 'Design system updates',
          timeEntryId: 'entry46',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 5, minutes: 15)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 4, minutes: 45)),
          categoryId: 6,
          categoryName: 'UI Design'),
      TimeEntry(
          description: 'Load testing analysis',
          timeEntryId: 'entry47',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 4, minutes: 45)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 4, minutes: 15)),
          categoryId: 7,
          categoryName: 'Testing'),
      TimeEntry(
          description: 'User guide documentation',
          timeEntryId: 'entry48',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 4, minutes: 15)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 3, minutes: 45)),
          categoryId: 8,
          categoryName: 'Documentation'),
      TimeEntry(
          description: 'Performance monitoring setup',
          timeEntryId: 'entry49',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 3, minutes: 45)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 3, minutes: 15)),
          categoryId: 9,
          categoryName: 'Optimization'),
      TimeEntry(
          description: 'SSL certificate renewal',
          timeEntryId: 'entry50',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 3, minutes: 15)),
          endTime: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
          categoryId: 10,
          categoryName: 'Security'),
      TimeEntry(
          description: 'Client feedback session',
          timeEntryId: 'entry51',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 2, minutes: 30)),
          categoryId: 11,
          categoryName: 'Client Work'),
      TimeEntry(
          description: 'README file updates',
          timeEntryId: 'entry52',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 2, minutes: 30)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 2, minutes: 15)),
          categoryId: 8,
          categoryName: 'Documentation'),
      TimeEntry(
          description: 'CSS animation bug fix',
          timeEntryId: 'entry53',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 2, minutes: 15)),
          endTime: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
          categoryId: 4,
          categoryName: 'Bug Fix'),
      TimeEntry(
          description: 'Dashboard widget design',
          timeEntryId: 'entry54',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 1, minutes: 30)),
          categoryId: 6,
          categoryName: 'UI Design'),
      TimeEntry(
          description: 'Sprint review meeting',
          timeEntryId: 'entry55',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 1, minutes: 30)),
          endTime: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
          categoryId: 1,
          categoryName: 'Meetings'),
      TimeEntry(
          description: 'Agile planning session',
          timeEntryId: 'entry56',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
          endTime:
              DateTime.now().subtract(const Duration(days: 2, minutes: 45)),
          categoryId: 13,
          categoryName: 'Planning'),
      TimeEntry(
          description: 'Microservice implementation',
          timeEntryId: 'entry57',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 2, minutes: 45)),
          endTime:
              DateTime.now().subtract(const Duration(days: 2, minutes: 30)),
          categoryId: 3,
          categoryName: 'Development'),
      TimeEntry(
          description: 'Team chat discussions',
          timeEntryId: 'entry58',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 2, minutes: 30)),
          endTime:
              DateTime.now().subtract(const Duration(days: 2, minutes: 15)),
          categoryId: 12,
          categoryName: 'Communication'),
      TimeEntry(
          description: 'Next sprint preparation',
          timeEntryId: 'entry59',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 2, minutes: 15)),
          endTime: DateTime.now().subtract(const Duration(days: 2, minutes: 5)),
          categoryId: 13,
          categoryName: 'Planning'),
      TimeEntry(
          description: 'Daily summary notes',
          timeEntryId: 'entry60',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 2, minutes: 5)),
          endTime: DateTime.now().subtract(const Duration(days: 2)),
          categoryId: 8,
          categoryName: 'Documentation'),
    ],

    // Day 3 (3 days ago)
    DateTime.now().subtract(const Duration(days: 3)): [
      TimeEntry(
          description: 'Architecture planning meeting',
          timeEntryId: 'entry61',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 3, hours: 8)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 7, minutes: 15)),
          categoryId: 1,
          categoryName: 'Meetings'),
      TimeEntry(
          description: 'Pull request reviews',
          timeEntryId: 'entry62',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 7, minutes: 15)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 6, minutes: 45)),
          categoryId: 2,
          categoryName: 'Code Review'),
      TimeEntry(
          description: 'React component development',
          timeEntryId: 'entry63',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 6, minutes: 45)),
          endTime: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
          categoryId: 3,
          categoryName: 'Development'),
      TimeEntry(
          description: 'Memory leak investigation',
          timeEntryId: 'entry64',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 5, minutes: 30)),
          categoryId: 4,
          categoryName: 'Bug Fix'),
      TimeEntry(
          description: 'SQL query performance tuning',
          timeEntryId: 'entry65',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 5, minutes: 30)),
          endTime: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
          categoryId: 5,
          categoryName: 'Database'),
      TimeEntry(
          description: 'Wireframe creation',
          timeEntryId: 'entry66',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 4, minutes: 30)),
          categoryId: 6,
          categoryName: 'UI Design'),
      TimeEntry(
          description: 'End-to-end testing',
          timeEntryId: 'entry67',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 4, minutes: 30)),
          endTime: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
          categoryId: 7,
          categoryName: 'Testing'),
      TimeEntry(
          description: 'Changelog preparation',
          timeEntryId: 'entry68',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 3, minutes: 45)),
          categoryId: 8,
          categoryName: 'Documentation'),
      TimeEntry(
          description: 'Bundle size optimization',
          timeEntryId: 'entry69',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 3, minutes: 45)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 3, minutes: 15)),
          categoryId: 9,
          categoryName: 'Optimization'),
      TimeEntry(
          description: 'Authentication system review',
          timeEntryId: 'entry70',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 3, minutes: 15)),
          endTime: DateTime.now().subtract(const Duration(days: 3, hours: 3)),
          categoryId: 10,
          categoryName: 'Security'),
      TimeEntry(
          description: 'Client progress update',
          timeEntryId: 'entry71',
          userId: 'user1',
          startTime: DateTime.now().subtract(const Duration(days: 3, hours: 3)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 2, minutes: 30)),
          categoryId: 11,
          categoryName: 'Client Work'),
      TimeEntry(
          description: 'Installation guide writing',
          timeEntryId: 'entry72',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 2, minutes: 30)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 2, minutes: 15)),
          categoryId: 8,
          categoryName: 'Documentation'),
      TimeEntry(
          description: 'Cross-browser compatibility fix',
          timeEntryId: 'entry73',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 2, minutes: 15)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 1, minutes: 45)),
          categoryId: 4,
          categoryName: 'Bug Fix'),
      TimeEntry(
          description: 'Icon set design',
          timeEntryId: 'entry74',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 1, minutes: 45)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 1, minutes: 15)),
          categoryId: 6,
          categoryName: 'UI Design'),
      TimeEntry(
          description: 'Quarterly planning meeting',
          timeEntryId: 'entry75',
          userId: 'user1',
          startTime: DateTime.now()
              .subtract(const Duration(days: 3, hours: 1, minutes: 15)),
          endTime:
              DateTime.now().subtract(const Duration(days: 3, minutes: 45)),
          categoryId: 13,
          categoryName: 'Planning'),
      TimeEntry(
          description: 'Stakeholder alignment call',
          timeEntryId: 'entry76',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 3, minutes: 45)),
          endTime:
              DateTime.now().subtract(const Duration(days: 3, minutes: 30)),
          categoryId: 1,
          categoryName: 'Meetings'),
      TimeEntry(
          description: 'GraphQL schema updates',
          timeEntryId: 'entry77',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 3, minutes: 30)),
          endTime:
              DateTime.now().subtract(const Duration(days: 3, minutes: 15)),
          categoryId: 3,
          categoryName: 'Development'),
      TimeEntry(
          description: 'Internal team communication',
          timeEntryId: 'entry78',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 3, minutes: 15)),
          endTime:
              DateTime.now().subtract(const Duration(days: 3, minutes: 10)),
          categoryId: 12,
          categoryName: 'Communication'),
      TimeEntry(
          description: 'Roadmap planning',
          timeEntryId: 'entry79',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 3, minutes: 10)),
          endTime: DateTime.now().subtract(const Duration(days: 3, minutes: 5)),
          categoryId: 13,
          categoryName: 'Planning'),
      TimeEntry(
          description: 'Knowledge sharing session',
          timeEntryId: 'entry80',
          userId: 'user1',
          startTime:
              DateTime.now().subtract(const Duration(days: 3, minutes: 5)),
          endTime: DateTime.now().subtract(const Duration(days: 3)),
          categoryId: 8,
          categoryName: 'Documentation'),
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Provider.of<ThemeProvider>(context).isDarkMode
          ? scaffoldColorDark
          : scaffoldColorLight,
      child: ListView.builder(
        physics: timelineWidgetScrollPhysics,
        shrinkWrap: timelineWidgetShrinkWrap,
        itemCount: map.length,
        itemBuilder: (context, index) => DayTimelineWidget(
          date: map.keys.elementAt(index),
          list: map[map.keys.elementAt(index)]!,
        ),
      ),
    );
  }
}
