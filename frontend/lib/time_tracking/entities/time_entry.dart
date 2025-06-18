class TimeEntry {
  String _description;
  String _timeEntryId;
  String _userId;
  DateTime _startTime;
  DateTime? _endTime;
  int _categoryId;
  String _categoryName;

  TimeEntry({
    required String description,
    required String timeEntryId,
    required String userId,
    required DateTime startTime,
    DateTime? endTime,
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
  DateTime? get endTime => _endTime;
  int get categoryId => _categoryId;
  String get categoryName => _categoryName;

  set description(String value) => _description = value;
  set timeEntryId(String value) => _timeEntryId = value;
  set userId(String value) => _userId = value;
  set startTime(DateTime value) => _startTime = value;
  set endTime(DateTime? value) => _endTime = value;
  set categoryId(int value) => _categoryId = value;
  set categoryName(String value) => _categoryName = value;

  Duration get duration => (_endTime ?? DateTime.now()).difference(_startTime);
}
