import 'dart:async';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
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
  bool _sessionInvalidated = false;

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
    if (widget.isStrict && widget.routineType.isNotEmpty && !_sessionInvalidated) {
      await StrictModeService().markCompleted(widget.routineType);
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionScreen(
          durationMinutes: _sessionInvalidated ? 0 : widget.totalMinutes,
        ),
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

  /// Show confirmation dialog before opening an allowed app in strict mode.
  /// Timer keeps running, but the session is marked as invalidated.
  void _confirmOpenApp(AppInfo app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Buka ${app.name}?",
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "⚠ Peringatan: Membuka aplikasi lain akan membatalkan sesi detox ini. 0 menit akan tercatat.",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Timer akan tetap berjalan, tapi sesi ini tidak akan dihitung sebagai detox yang berhasil.",
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Tetap Detox",
              style: TextStyle(color: AppTheme.primarySage, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade100,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _sessionInvalidated = true);
              // Timer keeps running — session is invalidated
              await InstalledApps.startApp(app.packageName);
            },
            child: const Text("Buka Aplikasi"),
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
    final detoxProvider = context.watch<DetoxProvider>();
    final selectedActivities = detoxProvider.selectedActivities;
    final allowedApps = detoxProvider.allowedApps;

    return PopScope(
      canPop: !widget.isStrict,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.isStrict) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Strict Detox aktif. Kamu tidak bisa keluar."),
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
                // ── Header ──
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

                // ── Invalidated banner (appears after opening an app) ──
                if (_sessionInvalidated) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Sesi dibatalkan — kamu membuka aplikasi lain. 0 menit akan tercatat.",
                            style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ── Timer ring ──
                Center(
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: _sessionInvalidated
                                ? Colors.red.shade100
                                : AppTheme.lightSage,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _sessionInvalidated
                                  ? Colors.redAccent.shade100
                                  : AppTheme.primarySage,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(_remainingSeconds),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: _sessionInvalidated
                                    ? Colors.redAccent.shade100
                                    : AppTheme.textDark,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _sessionInvalidated ? "invalidated" : "remaining",
                              style: TextStyle(
                                color: _sessionInvalidated
                                    ? Colors.redAccent.shade100
                                    : AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Content area: activities OR allowed apps list ──
                if (widget.isStrict) ...[
                  // ── Strict Mode: show allowed apps inline ──
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 16, color: AppTheme.primarySage),
                        SizedBox(width: 6),
                        Text(
                          "Aplikasi yang Diizinkan",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Warning banner
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "⚠ Membuka aplikasi = sesi detox dibatalkan (0 menit tercatat)",
                            style: TextStyle(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Allowed apps list
                  Expanded(
                    child: allowedApps.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.apps_rounded, size: 40, color: AppTheme.textMuted.withValues(alpha: 0.4)),
                                const SizedBox(height: 8),
                                const Text(
                                  "Belum ada aplikasi yang diizinkan.\nAtur di Settings.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: allowedApps.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final app = allowedApps[index];
                              return Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: _sessionInvalidated
                                      ? () async {
                                          // Already invalidated, just open directly
                                          await InstalledApps.startApp(app.packageName);
                                        }
                                      : () => _confirmOpenApp(app),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFEFEFEA)),
                                    ),
                                    child: Row(
                                      children: [
                                        app.icon != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.memory(app.icon!, width: 36, height: 36),
                                              )
                                            : Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.lightSage,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(Icons.android, size: 22, color: AppTheme.primarySage),
                                              ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            app.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.open_in_new_rounded, size: 16, color: AppTheme.textMuted),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    "🔒 Strict Mode Active • Cannot be canceled early",
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                  ),
                ] else ...[
                  // ── Normal mode: show activity suggestions ──
                  if (selectedActivities.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Ideas for this moment:",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
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
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textDark),
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
                      style: TextStyle(fontSize: 15, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                    ),
                    const Spacer(),
                  ],
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _confirmCancel,
                    icon: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                    label: const Text(
                      "End session",
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}