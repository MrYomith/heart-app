import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;

  const TaskItem({super.key, required this.task, required this.onToggle});

  Color get _timeColor {
    switch (task.timeColor) {
      case 'orange':
        return AppColors.warning;
      case 'red':
        return AppColors.primary;
      default:
        return AppColors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Opacity(
        opacity: task.done ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(task.icon, style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        decoration: task.done ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      task.subtitle,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: _timeColor),
                      const SizedBox(width: 3),
                      Text(task.time, style: GoogleFonts.poppins(fontSize: 11, color: _timeColor, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _CheckCircle(done: task.done),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool done;
  const _CheckCircle({required this.done});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.teal : Colors.transparent,
        border: Border.all(color: done ? AppColors.teal : AppColors.border, width: 2),
      ),
      child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
    );
  }
}
