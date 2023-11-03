import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  ClockWidgetState createState() => ClockWidgetState();
}

class ClockWidgetState extends State<ClockWidget>
    with TickerProviderStateMixin {
  String formattedTime = '';
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      updateClock();
    });
    _ticker.start();
  }

  void updateClock() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd, HH:mm:ss');
    final formatted = formatter.format(now);
    setState(() {
      formattedTime = formatted;
    });
  }

  @override
  void dispose() {
    _ticker.dispose(); // Cancel the ticker when the widget is disposed
    super.dispose();
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
