import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detox_provider.dart';
import '../services/strict_mode_service.dart';
import '../theme/app_theme.dart';
import 'completion_screen.dart';

class DetoxTimerScreen extends StatefulWidget {
  final int totalMinutes;
  final bool isStrict;
  final String routineType;

  const DetoxTimerScreen({
    super.key,
    required this.totalMinutes,
    this.isStrict = false,
    this.routineType = '',
  });

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

  void _onComplete() async {
    if (widget.isStrict && widget.routineType.isNotEmpty) {
      await StrictModeService().markCompleted(widget.routineType);
    }

    if (!mounted) return;
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
    final selectedActivities = context.watch<DetoxProvider>().selectedActivities;

    return PopScope(
      canPop: !widget.isStrict,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.isStrict) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Strict Detox is active. Please stay present until the timer completes."),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isStrict) ...[
                      const Icon(Icons.lock_clock_rounded, size: 18, color: AppTheme.primarySage),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      widget.isStrict ? "Strict Digital Detox" : "Digital Detox",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primarySage,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Circular Progress Timer
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
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
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "remaining",
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Selected "Things To Do" Section
                if (selectedActivities.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ideas for this moment:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: selectedActivities.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final act = selectedActivities[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFEFEFEA)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: AppTheme.lightSage,
                                child: Icon(act.icon, size: 16, color: AppTheme.primarySage),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  act.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                  const Text(
                    "You've got this. Enjoy the silence.",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                ],

                const SizedBox(height: 12),

                if (!widget.isStrict)
                  TextButton.icon(
                    onPressed: _confirmCancel,
                    icon: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                    label: const Text(
                      "End session",
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "🔒 Strict mode active",
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}