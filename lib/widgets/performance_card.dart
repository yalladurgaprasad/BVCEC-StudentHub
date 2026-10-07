import 'package:flutter/material.dart';
import '../models/marks.dart';
import '../theme/app_theme.dart';

class PerformanceCard extends StatefulWidget {
  final MarksRecord record;
  final String studentName;
  final VoidCallback? onEdit;
  final bool showEdit;

  const PerformanceCard({
    super.key,
    required this.record,
    required this.studentName,
    this.onEdit,
    this.showEdit = false,
  });

  @override
  State<PerformanceCard> createState() => _PerformanceCardState();
}

class _PerformanceCardState extends State<PerformanceCard> {
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
              // Subject & Grade Header
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
                          'Student: ${widget.studentName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.record.gradeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: widget.record.gradeColor, width: 1.5),
                        ),
                        child: Text(
                          'Grade: ${widget.record.grade}',
                          style: TextStyle(
                            color: widget.record.gradeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (widget.showEdit && widget.onEdit != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: _isHovered ? AppTheme.primaryColor : null,
                          ),
                          onPressed: widget.onEdit,
                          tooltip: 'Edit Marks',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progress Bar for Marks Percentage
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: widget.record.percentage / 100.0,
                        minHeight: 10,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(widget.record.gradeColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.record.totalMarks.toStringAsFixed(1)}/100 (${widget.record.percentage.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.record.gradeColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Detailed Exam Breakdown Grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildComponentScore(context, 'Internal', '${widget.record.internalMarks}/20'),
                    _buildComponentScore(context, 'Assign', '${widget.record.assignmentMarks}/10'),
                    _buildComponentScore(context, 'Mid Exam', '${widget.record.midExam}/20'),
                    _buildComponentScore(context, 'Final Exam', '${widget.record.finalExam}/50'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentScore(
      BuildContext context, String label, String score) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          score,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
