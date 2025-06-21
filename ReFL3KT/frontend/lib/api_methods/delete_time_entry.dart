import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:http/http.dart' as http;

Future<bool> deleteTimeEntry(TimeEntry entry, String userId) async {
  final String apiUrl = dotenv.env['API_URL']!;

  try {
    final response = await http.delete(
      Uri.parse(
          "${apiUrl}api/users/${userId}/time-entries/${entry.timeEntryId}/"),
    );

    if (response.statusCode == 204) {
      print("Time entry deleted successfully");
      return true;
    } else {
      print("Failed to delete time entry: ${response.statusCode}");
      print("Response body: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error deleting time entry: $e");
    return false;
  }
}
