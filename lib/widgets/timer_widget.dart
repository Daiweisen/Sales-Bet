import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;

  const CountdownTimer({super.key, required this.endTime});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Stream<Duration> _timerStream;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.endTime.difference(DateTime.now());
    if (remaining.isNegative) {
      return const Text('Event started!');
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(remaining.inHours);
    final minutes = twoDigits(remaining.inMinutes.remainder(60));
    final seconds = twoDigits(remaining.inSeconds.remainder(60));

    return Text(
      'Time remaining: $hours:$minutes:$seconds',
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}