import 'dart:convert';

class SessionRecord {
  final String id;
  final DateTime timestamp;
  final int durationMinutes;
  final String mode; // 'focus', 'shortBreak', 'longBreak'
  final String? taskTitle;

  const SessionRecord({
    required this.id,
    required this.timestamp,
    required this.durationMinutes,
    required this.mode,
    this.taskTitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'durationMinutes': durationMinutes,
      'mode': mode,
      'taskTitle': taskTitle,
    };
  }

  factory SessionRecord.fromMap(Map<String, dynamic> map) {
    return SessionRecord(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      durationMinutes: map['durationMinutes'] as int? ?? 25,
      mode: map['mode'] as String? ?? 'focus',
      taskTitle: map['taskTitle'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory SessionRecord.fromJson(String source) =>
      SessionRecord.fromMap(json.decode(source) as Map<String, dynamic>);
}
