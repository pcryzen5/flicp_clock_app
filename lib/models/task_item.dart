import 'dart:convert';

class TaskItem {
  final String id;
  final String title;
  final String notes;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final bool isCompleted;
  final String tag; // 'Work', 'Study', 'Coding', 'Design', 'Personal'
  final DateTime createdAt;

  const TaskItem({
    required this.id,
    required this.title,
    this.notes = '',
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.isCompleted = false,
    this.tag = 'Work',
    required this.createdAt,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? notes,
    int? estimatedPomodoros,
    int? completedPomodoros,
    bool? isCompleted,
    String? tag,
    DateTime? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      isCompleted: isCompleted ?? this.isCompleted,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
      'isCompleted': isCompleted,
      'tag': tag,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] as String? ?? 'Untitled Task',
      notes: map['notes'] as String? ?? '',
      estimatedPomodoros: map['estimatedPomodoros'] as int? ?? 1,
      completedPomodoros: map['completedPomodoros'] as int? ?? 0,
      isCompleted: map['isCompleted'] as bool? ?? false,
      tag: map['tag'] as String? ?? 'Work',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskItem.fromJson(String source) =>
      TaskItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
