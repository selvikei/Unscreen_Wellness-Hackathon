import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detox_provider.dart';
import '../theme/app_theme.dart';

class ThingsToDoScreen extends StatelessWidget {
  const ThingsToDoScreen({super.key});

  // Material Icons library palette for user customization
  static const List<IconData> availableIcons = [
    Icons.self_improvement_rounded,
    Icons.edit_note_rounded,
    Icons.fitness_center_rounded,
    Icons.menu_book_rounded,
    Icons.park_rounded,
    Icons.brush_rounded,
    Icons.music_note_rounded,
    Icons.coffee_rounded,
    Icons.directions_walk_rounded,
    Icons.clean_hands_rounded,
    Icons.local_florist_rounded,
    Icons.spa_rounded,
    Icons.palette_rounded,
    Icons.pool_rounded,
    Icons.nights_stay_rounded,
  ];

  void _showAddActivityDialog(BuildContext context) {
    final textController = TextEditingController();
    IconData selectedIcon = availableIcons.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "New Activity",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Activity name (e.g. Draw, Brew Tea)",
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFEFEFEA)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Choose an Icon",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableIcons.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final icon = availableIcons[index];
                        final isSel = selectedIcon == icon;
                        return InkWell(
                          onTap: () => setModalState(() => selectedIcon = icon),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.lightSage : AppTheme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppTheme.primarySage : const Color(0xFFEFEFEA),
                                width: isSel ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: isSel ? AppTheme.primarySage : AppTheme.textDark,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = textController.text.trim();
                        if (name.isNotEmpty) {
                          context.read<DetoxProvider>().addCustomActivity(name, selectedIcon);
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text("Add Activity"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DetoxProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Things To Do",
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose what you'd like to do while unplugged. Selected activities appear below your active detox timer.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  itemCount: provider.activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = provider.activities[index];
                    return InkWell(
                      onTap: () => provider.toggleActivity(item.id),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: item.isSelected ? AppTheme.lightSage.withOpacity(0.5) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: item.isSelected ? AppTheme.primarySage : const Color(0xFFEFEFEA),
                            width: item.isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: item.isSelected ? AppTheme.primarySage : AppTheme.lightSage,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.icon,
                                color: item.isSelected ? Colors.white : AppTheme.textDark,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: item.isSelected,
                              activeColor: AppTheme.primarySage,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onChanged: (_) => provider.toggleActivity(item.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddActivityDialog(context),
                  icon: const Icon(Icons.add, color: AppTheme.primarySage),
                  label: const Text(
                    "Add Custom Activity",
                    style: TextStyle(
                      color: AppTheme.primarySage,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primarySage, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}