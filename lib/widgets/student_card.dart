import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

class StudentCard extends StatefulWidget {
  final Student student;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final student = widget.student;

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
          margin: const EdgeInsets.symmetric(vertical: 6),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered && !disableAnimations ? -3.0 : 0.0)
            ..scale(_isPressed && !disableAnimations ? 0.98 : 1.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? AppTheme.primaryColor.withValues(alpha: 0.5)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: _isHovered ? 0.16 : 0.05),
                blurRadius: _isHovered ? 16 : 8,
                spreadRadius: _isHovered ? 1 : 0,
                offset: Offset(0, _isHovered ? 6 : 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with Student Initials & Hover Scale
                    AnimatedScale(
                      scale: _isHovered && !disableAnimations ? 1.08 : 1.0,
                      duration: Duration(milliseconds: disableAnimations ? 0 : 180),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                        child: Text(
                          _getInitials(student.name),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Student Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  student.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _isHovered ? AppTheme.primaryColor : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  student.studentId,
                                  style: const TextStyle(
                                    color: AppTheme.secondaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Roll: ${student.rollNumber} • ${student.email}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),

                          // Badges for Dept, Year, Section
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildBadge(
                                context,
                                student.department,
                                Icons.school_outlined,
                                Colors.indigo,
                              ),
                              _buildBadge(
                                context,
                                '${student.year} (${student.section})',
                                Icons.calendar_today_outlined,
                                Colors.teal,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Edit / Delete Actions (if Admin / Faculty)
                    if (widget.showActions) ...[
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: isDark ? Colors.white70 : Colors.grey[700]),
                        onSelected: (value) {
                          if (value == 'edit' && widget.onEdit != null) {
                            widget.onEdit!();
                          } else if (value == 'delete' && widget.onDelete != null) {
                            widget.onDelete!();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                SizedBox(width: 10),
                                Text('Edit Student'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                SizedBox(width: 10),
                                Text('Delete Student'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
      BuildContext context, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'S';
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
