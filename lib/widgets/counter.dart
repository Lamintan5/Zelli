import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeCounter extends StatefulWidget {
  final int time;
  final double fontSize;
  const TimeCounter({super.key, required this.time, this.fontSize = 20});

  @override
  State<TimeCounter> createState() => _TimeCounterState();
}

class _TimeCounterState extends State<TimeCounter> {
  Timer? _timer;
  int _remainingTime = 10 * 60;

  void _startCountdown() {
    DateTime targetDateTime = DateTime.fromMillisecondsSinceEpoch(widget.time);
    Duration initialRemaining = targetDateTime.difference(DateTime.now());
    _remainingTime = initialRemaining.inSeconds;

    _timer?.cancel(); // Cancel any existing timer before starting a new one
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _remainingTime--;
      });
      if (_remainingTime <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(TimeCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time) {
      _startCountdown(); // Restart the countdown with the new time
    }
  }

  @override
  Widget build(BuildContext context) {

    return Text(_formatTime(_remainingTime), style: TextStyle(fontSize: widget.fontSize, color: CupertinoColors.activeBlue, fontWeight: FontWeight.w600));
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  String _formatTime(int time) {
    int minutes = time ~/ 60;
    int seconds = time % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
