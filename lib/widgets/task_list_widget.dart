import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_item.dart';
import '../theme/app_theme.dart';

class TaskListWidget extends StatefulWidget {
  final List<TaskItem> tasks;
  final String? activeTaskId;
  final AppThemeData themeData;
  final ValueChanged<TaskItem> onToggleComplete;
  final ValueChanged<String> onSelectActiveTask;
  final ValueChanged<TaskItem> onAddTask;
  final ValueChanged<TaskItem> onUpdateTask;
  final ValueChanged<String> onDeleteTask;

  const TaskListWidget({
    super.key,
    required this.tasks,
    required this.activeTaskId,
    required this.themeData,
    required this.onToggleComplete,
    required this.onSelectActiveTask,
    required this.onAddTask,
    required this.onUpdateTask,
    required this.onDeleteTask,
  });

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class TaskDialogHelper {
  static Color getTagColor(String tag, AppThemeData themeData) {
    switch (tag) {
      case 'Work':
        return const Color(0xFF3B82F6);
      case 'Study':
        return const Color(0xFF8B5CF6);
      case 'Coding':
        return const Color(0xFF10B981);
      case 'Design':
        return const Color(0xFFEC4899);
      case 'Personal':
        return const Color(0xFFF59E0B);
      default:
        return themeData.focusColor;
    }
  }

  static void showAddOrEditTaskDialog(
    BuildContext context, {
    required AppThemeData themeData,
    TaskItem? existingTask,
    required ValueChanged<TaskItem> onSave,
  }) {
    final titleController = TextEditingController(text: existingTask?.title ?? '');
    final notesController = TextEditingController(text: existingTask?.notes ?? '');
    int estimated = existingTask?.estimatedPomodoros ?? 2;
    String selectedTag = existingTask?.tag ?? 'Work';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: themeData.bgCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: themeData.cardBorder),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sheet Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existingTask == null ? 'Add New Task' : 'Edit Task',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: themeData.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: themeData.textSecondary,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title Input
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      style: GoogleFonts.plusJakartaSans(
                        color: themeData.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'What are you focusing on?',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: themeData.textSecondary,
                        ),
                        filled: true,
                        fillColor: themeData.bgCardLight,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeData.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeData.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeData.focusColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Notes Input
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      style: GoogleFonts.plusJakartaSans(
                        color: themeData.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Notes or steps (optional)',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: themeData.textSecondary,
                        ),
                        filled: true,
                        fillColor: themeData.bgCardLight,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeData.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeData.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeData.focusColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Estimated Pomodoros counter
                    Text(
                      'Estimated Pomodoros',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: themeData.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _RoundCounterBtn(
                          icon: Icons.remove_rounded,
                          onPressed: estimated > 1
                              ? () => setModalState(() => estimated--)
                              : null,
                          themeData: themeData,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Text(
                                '$estimated',
                                style: AppFonts.mono(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: themeData.focusColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('🍅', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        _RoundCounterBtn(
                          icon: Icons.add_rounded,
                          onPressed: estimated < 12
                              ? () => setModalState(() => estimated++)
                              : null,
                          themeData: themeData,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Tag Selector
                    Text(
                      'Category Tag',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: themeData.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Work', 'Study', 'Coding', 'Design', 'Personal'].map((tag) {
                        final isSelected = selectedTag == tag;
                        final tagColor = getTagColor(tag, themeData);
                        return ChoiceChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setModalState(() => selectedTag = tag);
                          },
                          backgroundColor: themeData.bgCardLight,
                          selectedColor: tagColor.withValues(alpha: 0.25),
                          labelStyle: GoogleFonts.plusJakartaSans(
                            color: isSelected ? tagColor : themeData.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? tagColor : themeData.cardBorder,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeData.focusColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final text = titleController.text.trim();
                          if (text.isEmpty) return;

                          if (existingTask == null) {
                            final newTask = TaskItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: text,
                              notes: notesController.text.trim(),
                              estimatedPomodoros: estimated,
                              completedPomodoros: 0,
                              isCompleted: false,
                              tag: selectedTag,
                              createdAt: DateTime.now(),
                            );
                            onSave(newTask);
                          } else {
                            final updated = existingTask.copyWith(
                              title: text,
                              notes: notesController.text.trim(),
                              estimatedPomodoros: estimated,
                              tag: selectedTag,
                            );
                            onSave(updated);
                          }

                          Navigator.pop(context);
                        },
                        child: Text(
                          existingTask == null ? 'Create Task' : 'Save Changes',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: themeData.brightness == Brightness.dark
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TaskListWidgetState extends State<TaskListWidget> {
  String _filter = 'All'; // 'All', 'Active', 'Completed'
  String? _selectedTagFilter;

  final List<String> _tags = ['All', 'Work', 'Study', 'Coding', 'Design', 'Personal'];

  Color _getTagColor(String tag) => TaskDialogHelper.getTagColor(tag, widget.themeData);

  void _showAddOrEditTaskDialog([TaskItem? existingTask]) {
    TaskDialogHelper.showAddOrEditTaskDialog(
      context,
      themeData: widget.themeData,
      existingTask: existingTask,
      onSave: (task) {
        if (existingTask == null) {
          widget.onAddTask(task);
        } else {
          widget.onUpdateTask(task);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter tasks
    final filtered = widget.tasks.where((t) {
      if (_filter == 'Active' && t.isCompleted) return false;
      if (_filter == 'Completed' && !t.isCompleted) return false;
      if (_selectedTagFilter != null && _selectedTagFilter != 'All') {
        if (t.tag != _selectedTagFilter) return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tasks Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Focus Tasks',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: widget.themeData.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.themeData.bgCardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.themeData.cardBorder),
                  ),
                  child: Text(
                    '${widget.tasks.where((t) => !t.isCompleted).length} pending',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.themeData.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            // Add Task Button
            TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: widget.themeData.focusColor.withValues(alpha: 0.12),
                foregroundColor: widget.themeData.focusColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: widget.themeData.focusColor.withValues(alpha: 0.3)),
                ),
              ),
              onPressed: () => _showAddOrEditTaskDialog(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'Add Task',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Status Filters
              ...['All', 'Active', 'Completed'].map((status) {
                final isSelected = _filter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _filter = status);
                    },
                    backgroundColor: widget.themeData.bgCard,
                    selectedColor: widget.themeData.focusColor.withValues(alpha: 0.2),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: isSelected ? widget.themeData.focusColor : widget.themeData.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? widget.themeData.focusColor : widget.themeData.cardBorder,
                      ),
                    ),
                  ),
                );
              }),

              Container(
                height: 20,
                width: 1,
                color: widget.themeData.cardBorder,
                margin: const EdgeInsets.symmetric(horizontal: 6),
              ),

              // Category Tag Filter
              ..._tags.map((tag) {
                final isSelected = (_selectedTagFilter ?? 'All') == tag;
                final tagColor = _getTagColor(tag);
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedTagFilter = tag;
                      });
                    },
                    backgroundColor: widget.themeData.bgCard,
                    selectedColor: tagColor.withValues(alpha: 0.25),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: isSelected ? tagColor : widget.themeData.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? tagColor : widget.themeData.cardBorder,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tasks List / Empty State
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: widget.themeData.bgCard.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.themeData.cardBorder, strokeAlign: BorderSide.strokeAlignInside),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: widget.themeData.focusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.playlist_add_check_circle_outlined,
                    size: 38,
                    color: widget.themeData.focusColor,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.tasks.isEmpty ? 'Your task board is fresh & empty' : 'No tasks in this filter',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: widget.themeData.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.tasks.isEmpty
                      ? 'Add your first task to start organizing your work and tracking your focus sessions.'
                      : 'Try selecting a different filter or tap "+ Add Task" to create one.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: widget.themeData.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeData.focusColor,
                    foregroundColor: widget.themeData.brightness == Brightness.dark
                        ? Colors.black87
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _showAddOrEditTaskDialog(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    widget.tasks.isEmpty ? 'Create First Task' : 'Add Task',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final task = filtered[index];
              final isActive = widget.activeTaskId == task.id;
              final tagColor = _getTagColor(task.tag);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? widget.themeData.focusColor.withValues(alpha: 0.08)
                      : widget.themeData.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive
                        ? widget.themeData.focusColor.withValues(alpha: 0.6)
                        : widget.themeData.cardBorder,
                    width: isActive ? 1.5 : 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: widget.themeData.focusColor.withValues(alpha: 0.15),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Custom Checkbox
                    GestureDetector(
                      onTap: () => widget.onToggleComplete(task),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.isCompleted
                              ? widget.themeData.focusColor
                              : Colors.transparent,
                          border: Border.all(
                            color: task.isCompleted
                                ? widget.themeData.focusColor
                                : widget.themeData.cardBorder,
                            width: 1.8,
                          ),
                        ),
                        child: task.isCompleted
                            ? Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: widget.themeData.brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Task details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Title
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: task.isCompleted
                                        ? widget.themeData.textSecondary
                                        : widget.themeData.textPrimary,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),

                              // Tag pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: tagColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  task.tag,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: tagColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (task.notes.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              task.notes,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: widget.themeData.textSecondary,
                              ),
                            ),
                          ],

                          const SizedBox(height: 6),

                          // Pomodoro progress chip (e.g. 🍅 2 / 4)
                          Row(
                            children: [
                              Text(
                                '🍅 ${task.completedPomodoros} / ${task.estimatedPomodoros}',
                                style: AppFonts.mono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: widget.themeData.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Set Active / Active Badge
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: widget.themeData.focusColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'ACTIVE FOCUS',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: widget.themeData.focusColor,
                                    ),
                                  ),
                                )
                              else if (!task.isCompleted)
                                InkWell(
                                  onTap: () => widget.onSelectActiveTask(task.id),
                                  child: Text(
                                    'Focus on this',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: widget.themeData.focusColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions popup
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 18,
                        color: widget.themeData.textSecondary,
                      ),
                      color: widget.themeData.bgCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: widget.themeData.cardBorder),
                      ),
                      onSelected: (val) {
                        if (val == 'edit') {
                          _showAddOrEditTaskDialog(task);
                        } else if (val == 'delete') {
                          widget.onDeleteTask(task.id);
                        } else if (val == 'focus') {
                          widget.onSelectActiveTask(task.id);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'focus',
                          child: Row(
                            children: [
                              Icon(Icons.play_circle_outline_rounded,
                                  size: 16, color: widget.themeData.focusColor),
                              const SizedBox(width: 8),
                              const Text('Set as Active'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded,
                                  size: 16, color: widget.themeData.textPrimary),
                              const SizedBox(width: 8),
                              const Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: const Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 16, color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _RoundCounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppThemeData themeData;

  const _RoundCounterBtn({
    required this.icon,
    required this.onPressed,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: themeData.bgCardLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: themeData.cardBorder),
          ),
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null ? themeData.textPrimary : themeData.textSecondary.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
