import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Get analytics for a specific category within a date range
///
/// [userId] - The user ID
/// [categoryId] - The category ID
/// [startTime] - Start date in YYYY-MM-DD format
/// [endTime] - End date in YYYY-MM-DD format
///
/// Returns analytics data as Map<String, dynamic>
Future<Map<String, dynamic>> getCategoryAnalytics({
  required String userId,
  required int categoryId,
  required DateTime startTime,
  required DateTime endTime,
}) async {
  print('🔍 getCategoryAnalytics called with:');
  print('   userId: $userId');
  print('   categoryId: $categoryId');
  print('   startTime: $startTime');
  print('   endTime: $endTime');
  final String apiUrl = dotenv.env['API_URL']!;
  // final uri = Uri.parse("${apiUrl});
  print(startTime);
  print(endTime);
  try {
    // Format DateTime to YYYY-MM-DD format
    final String formattedStartTime =
        '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}';
    final String formattedEndTime =
        '${endTime.year}-${endTime.month.toString().padLeft(2, '0')}-${endTime.day.toString().padLeft(2, '0')}';

    print('📅 Formatted dates:');
    print('   formattedStartTime: $formattedStartTime');
    print('   formattedEndTime: $formattedEndTime');

    final url = Uri.parse(
        '${apiUrl}api/users/$userId/categories/$categoryId/analytics/?_startTime=$formattedStartTime&_endTime=$formattedEndTime');

    print('🌐 Making request to URL: $url');
    print('📤 Request headers: Content-Type: application/json');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Add authorization header if needed
        // 'Authorization': 'Bearer $token',
      },
    );

    print('📥 Response received:');
    print('   Status code: ${response.statusCode}');
    print('   Response headers: ${response.headers}');
    print('   Response body length: ${response.body.length} characters');

    if (response.statusCode == 200) {
      print('✅ Request successful, parsing JSON...');
      final data = json.decode(response.body) as Map<String, dynamic>;
      print('📊 Parsed data keys: ${data.keys.toList()}');
      print(
          '📊 Data preview: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}${data.toString().length > 200 ? "..." : ""}');
      return data;
    } else {
      print('❌ HTTP error occurred');
      print('   Response body: ${response.body}');
      throw Exception('HTTP error! status: ${response.statusCode}');
    }
  } catch (error) {
    print('💥 Error fetching category analytics: $error');
    print('   Error type: ${error.runtimeType}');
    rethrow;
  }
}

// Usage example:
// try {
//   final analytics = await getCategoryAnalytics(
//     userId: '123',
//     categoryId: 456,
//     startTime: DateTime(2024, 3, 1),
//     endTime: DateTime(2024, 3, 20),
//   );
//   print(analytics);
// } catch (error) {
//   print('Error: $error');
// }
