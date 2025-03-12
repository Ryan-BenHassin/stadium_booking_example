import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingService {
  final String baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:1337/api'
      : 'http://localhost:1337/api';

  Future<List<DateTime>> fetchAvailableDatetimes(String documentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/available-datetimes/$documentId'),
    );

    if (response.statusCode == 200) {
      // print("\n\nRESPONSE : ${response.body}\n\n");
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'] ?? [];
      return data.map((dateStr) => DateTime.parse(dateStr.toString())).toList();
    } else {
      throw Exception('Failed to load available datetimes');
    }
  }
}
