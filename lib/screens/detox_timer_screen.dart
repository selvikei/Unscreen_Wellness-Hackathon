import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'completion_screen.dart';

class DetoxTimerScreen extends StatefulWidget {
  final int totalMinutes;

  const DetoxTimerScreen({super.key, required this.totalMinutes});

  @override
  State<DetoxTimerScreen> createState() => _DetoxTimerScreenState();
}

class _DetoxTimerScreenState extends State<DetoxTimerScreen> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _onComplete();
      }
    });
  }

  void _onComplete() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionScreen(durationMinutes: widget.totalMinutes),
      ),
    );
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("End session early?"),
        content: const Text("It is okay if you need to attend to something. You can always restart later."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Keep Going", style: TextStyle(color: AppTheme.primarySage)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("End Session", style: TextStyle(color: AppTheme.textMuted)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1.0 - (_remainingSeconds / (widget.totalMinutes * 60));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Digital Detox",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primarySage,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 60),

              // Visual Circular Progress Timer
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: AppTheme.lightSage,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primarySage),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_remainingSeconds),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "remaining",
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),
              const Text(
                "You've got this. Enjoy the silence.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textDark,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),

              TextButton.icon(
                onPressed: _confirmCancel,
                icon: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                label: const Text(
                  "End session",
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}