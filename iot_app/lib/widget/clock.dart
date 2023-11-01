import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  ClockWidgetState createState() => ClockWidgetState();
}

class ClockWidgetState extends State<ClockWidget> {
  String formattedTime = '';

  @override
  void initState() {
    super.initState();
    updateClock();
  }

  void updateClock() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd, HH:mm:ss');
    final formatted = formatter.format(now);
    setState(() {
      formattedTime = formatted;
    });
    Future.delayed(const Duration(seconds: 1), updateClock);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        formattedTime,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
