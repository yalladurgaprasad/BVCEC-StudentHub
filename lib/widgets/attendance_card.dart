import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../theme/app_theme.dart';

class AttendanceCard extends StatefulWidget {
  final AttendanceRecord record;
  final String studentName;
  final VoidCallback? onMarkPresent;
  final VoidCallback? onMarkAbsent;
  final bool isFaculty;

  const AttendanceCard({
    super.key,
    required this.record,
    required this.studentName,
    this.onMarkPresent,
    this.onMarkAbsent,
    this.isFaculty = true,
  });

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: disableAnimations ? 0 : 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered && !disableAnimations ? -3.0 : 0.0)
            ..scale(_isPressed && !disableAnimations ? 0.98 : 1.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? AppTheme.primaryColor
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppTheme.primaryColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: _isHovered ? 14 : 8,
                offset: Offset(0, _isHovered ? 6 : 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject & Status Badge Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.record.subject,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isHovered ? AppTheme.primaryColor : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Student: ${widget.studentName} (${widget.record.studentId})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.record.statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: widget.record.statusColor, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.record.isAtRisk ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          size: 14,
                          color: widget.record.statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.record.percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: widget.record.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Attendance Progress Indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: widget.record.percentage / 100.0,
                  minHeight: 10,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(widget.record.statusColor),
                ),
              ),
              const SizedBox(height: 14),

              // Class Stats Summary Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(context, 'Total', '${widget.record.totalClasses}', AppTheme.primaryColor),
                  _buildStatItem(context, 'Present', '${widget.record.presentClasses}', Colors.green),
                  _buildStatItem(context, 'Absent', '${widget.record.absentClasses}', Colors.red),
                ],
              ),

              // Quick Attendance Marking Buttons for Faculty
              if (widget.isFaculty && (widget.onMarkPresent != null || widget.onMarkAbsent != null)) ...[
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onMarkPresent,
                        icon: const Icon(Icons.check, size: 18, color: Colors.green),
                        label: const Text('Mark Present', style: TextStyle(color: Colors.green)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onMarkAbsent,
                        icon: const Icon(Icons.close, size: 18, color: Colors.red),
                        label: const Text('Mark Absent', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
