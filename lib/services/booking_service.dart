import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingService {
  final String baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:1337/api'
      : 'http://localhost:1337/api';

  final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNzQxOTUwNTc2LCJleHAiOjE3NDQ1NDI1NzZ9.YTafh_aZLP2YL37I-Ro6rSJQmnKyPfL5kFN10_HZFSE';
  
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

  Future<bool> createReservation({required int userID,required int complexId, required DateTime dateTime}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'data': {
            'date': dateTime.toUtc().toIso8601String(),
            'complex': {'id': complexId},
            'user': {'id': userID},
          }
        }),
      );

      print('Reservation status code: ${response.statusCode}');
      print('Reservation response body: ${response.body}');

      // Only 201 is success for creation
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating reservation: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserBookings({required int userID}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations?populate=complex&filters[user][id][\$eq]=$userID'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print(jsonResponse);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }
  
}
