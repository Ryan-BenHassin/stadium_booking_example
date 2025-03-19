import 'package:flutter/material.dart';
import 'package:mapbox_first/services/booking_service.dart';
import 'package:intl/intl.dart';
import '../utils/showFlushbar.dart';
import '../providers/user_provider.dart';

class BookingsScreen extends StatefulWidget {
  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingService _bookingService = BookingService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final bookings = await _bookingService.fetchUserBookings(
        userID: UserProvider.user!.id,
      );
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bookings: $e');
      if (!mounted) return;
      showFlushBar(
        context,
        message: 'Failed to load bookings. Please check your connection.',
        success: false,
        fromBottom: false,
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Bookings')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: _bookings.isEmpty
                  ? Center(child: Text('No bookings found'))
                  : ListView.builder(
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                        DateTime? date;
                        try {
                          // Parse UTC date and convert to local
                          date = DateTime.parse(booking['date'] ?? '').toLocal();
                        } catch (e) {
                          date = DateTime.now();
                        }
                        
                        final formattedDate = DateFormat('MMM d, y - HH:mm').format(date);
                        final complex = booking['complex'] ?? {};
                        
                        return ListTile(
                          title: Text(complex['title'] ?? 'Unknown Complex'),
                          subtitle: Text(formattedDate),
                          trailing: Text(booking['state'] ?? 'PENDING'),
                        );
                      },
                    ),
            ),
    );
  }
}
