import 'package:flutter/material.dart';

class CustomDateTimePicker extends StatefulWidget {
  const CustomDateTimePicker({super.key, required Null Function(dynamic x) onSelectTimeRange});

  @override
  CustomDateTimePickerState createState() => CustomDateTimePickerState();
}

class CustomDateTimePickerState extends State<CustomDateTimePicker> {
  DateTime selectedDateTime = DateTime.now();
  String selectedOption =  'Last Hour';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedOption,
          items: const [
            DropdownMenuItem<String>(
              value: 'Last Hour',
              child: Text('Last Hour'),
            ),
            DropdownMenuItem<String>(
              value: 'Last Date',
              child: Text('Last Date'),
            ),
            DropdownMenuItem<String>(
              value: 'Last Week',
              child: Text('Last Week'),
            ),
            DropdownMenuItem<String>(
              value: 'Last Month',
              child: Text('Last Month'),
            ),
          ],
          onChanged: (String? newValue) {
            setState(() {
              selectedOption = newValue ?? '';
              _handleOptionSelection(newValue ??'');
            });
          },
        ),
      ],
    );
  }

  void _handleOptionSelection(String option) {
    switch (option) {
      
      case 'Last Hour':
        _pickLastHour();
        break;
      case 'Last Date':
        _pickLastDate();
        break;
      case 'Last Week':
        _pickLastWeek();
        break;
      case 'Last Month':
        _pickLastMonth();
        break;
    }
  }

  void _pickLastHour() {
    setState(() {
      selectedDateTime = DateTime.now().subtract(const Duration(hours: 1));
    });
  }

  void _pickLastDate() {
    setState(() {
      selectedDateTime = DateTime.now().subtract(const Duration(days: 1));
    });
  }

  void _pickLastWeek() {
    setState(() {
      selectedDateTime = DateTime.now().subtract(const Duration(days: 7));
    });
  }

  void _pickLastMonth() {
    setState(() {
      selectedDateTime = DateTime.now().subtract(const Duration(days: 30));
    });
  }
}
