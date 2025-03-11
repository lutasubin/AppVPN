import 'dart:async';
import 'package:flutter/material.dart';

class CountDownTimer extends StatefulWidget {
  final bool startTimer;

  const CountDownTimer({super.key, required this.startTimer});

  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> {
  Duration _duration = Duration();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.startTimer) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(CountDownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startTimer != oldWidget.startTimer) {
      if (widget.startTimer) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Hủy bỏ bất kỳ bộ đếm nào đang tồn tại
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Kiểm tra xem widget còn được gắn kết không
        setState(() {
          _duration = Duration(seconds: _duration.inSeconds + 1);
        });
      }
    });
  }

  void _stopTimer() {
    if (mounted) {
      // Kiểm tra xem widget còn được gắn kết không
      setState(() {
        _timer?.cancel();
        _timer = null;
        _duration = Duration();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String twoDigit(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigit(_duration.inHours);
    final minutes = twoDigit(_duration.inMinutes.remainder(60));
    final seconds = twoDigit(_duration.inSeconds.remainder(60));

    return Text(
      '$hours:$minutes:$seconds',
      style: const TextStyle(
        fontSize: 50,
        color: const Color(0xFFFFFFFF),
      ),
    );
  }
}
