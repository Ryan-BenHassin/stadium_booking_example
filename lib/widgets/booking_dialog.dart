import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/complex.dart';
import '../services/booking_service.dart';

class BookingDialog extends StatefulWidget {
  final Complex complex;

  const BookingDialog({
    Key? key,
    required this.complex,
  }) : super(key: key);

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final BookingService _bookingService = BookingService();
  // Selected date and time
  DateTime? _selectedDate;
  String? _selectedTime;
  
  // Available dates and times from server
  Map<DateTime, List<String>> _dateTimeMap = {};

  @override
  void initState() {
    super.initState();
    _loadAvailableDatetimes();
  }

  // Load available dates and times from server
  Future<void> _loadAvailableDatetimes() async {
    try {
      final datetimes = await _bookingService.fetchAvailableDatetimes(widget.complex.documentId);
      setState(() {
        _dateTimeMap = _createDateTimeMap(datetimes);
      });
    } catch (e) {
      print('Error loading available datetimes: $e');
    }
  }

  // Convert list of dates into a map of date -> list of times
  Map<DateTime, List<String>> _createDateTimeMap(List<DateTime> datetimes) {
    final map = <DateTime, List<String>>{};
    
    for (var dt in datetimes) {
      final localDt = dt.toLocal(); // Convert to local timezone
      final date = DateTime(localDt.year, localDt.month, localDt.day);
      final time = '${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
      
      map.putIfAbsent(date, () => []).add(time);
    }

    // Sort times for each date
    map.forEach((_, times) => times.sort());
    return map;
  }

  // Check if a date has available times
  bool _isDateEnabled(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _dateTimeMap.containsKey(normalizedDay);
  }

  // Build the calendar widget
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(Duration(days: 365)),
      focusedDay: _selectedDate ?? DateTime.now(),
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      enabledDayPredicate: _isDateEnabled,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
          _selectedTime = null;
        });
      },
      calendarStyle: CalendarStyle(outsideDaysVisible: false),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  // Build the time dropdown
  Widget _buildTimeDropdown() {
    if (_selectedDate == null) return SizedBox.shrink();

    final date = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    final times = _dateTimeMap[date] ?? [];

    return DropdownButton<String>(
      isExpanded: true,
      hint: Text('Select time'),
      value: _selectedTime,
      items: times.map((time) => DropdownMenuItem(
        value: time,
        child: Text(time),
      )).toList(),
      onChanged: (value) => setState(() => _selectedTime = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Book ${widget.complex.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),

            // Calendar
            _buildCalendar(),
            SizedBox(height: 16),

            // Time Dropdown
            _buildTimeDropdown(),

            // Buttons
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                if (_selectedDate != null && _selectedTime != null)
                  TextButton(
                    onPressed: () {
                      // TODO: Handle booking confirmation
                      Navigator.pop(context);
                    },
                    child: Text('Confirm'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
