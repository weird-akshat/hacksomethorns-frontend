class TimeEntry {
  final String _description;
  final String _timeEntryId;
  final String _userId;
  final DateTime _startTime;
  final DateTime _endTime;
  final int _categoryId;
  final String _categoryName;

  TimeEntry({
    required String description,
    required String timeEntryId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required int categoryId,
    required String categoryName,
  })  : _description = description,
        _timeEntryId = timeEntryId,
        _userId = userId,
        _startTime = startTime,
        _endTime = endTime,
        _categoryId = categoryId,
        _categoryName = categoryName;

  String get description => _description;
  String get timeEntryId => _timeEntryId;
  String get userId => _userId;
  DateTime get startTime => _startTime;
  DateTime get endTime => _endTime;
  int get categoryId => _categoryId;
  String get categoryName => _categoryName;

  Duration get duration => _endTime.difference(_startTime);
}
