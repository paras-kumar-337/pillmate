import 'package:flutter/material.dart';

class Medicine {
  int? id;
  String name;
  String type;
  String strength;
  String? imagePath;
  String schedule; // e.g. "Every day"
  String dosageFrequency; // "Once a day"
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;
  bool reminders;
  bool taken; // whether marked taken for the current occurrence

  Medicine({
    this.id,
    this.name = '',
    this.type = 'Tablet',
    this.strength = '500 mg',
    this.imagePath,
    this.schedule = 'Every day',
    this.dosageFrequency = 'Once a day',
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.reminders = true,
    this.taken = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'strength': strength,
        'imagePath': imagePath,
        'schedule': schedule,
        'dosageFrequency': dosageFrequency,
        'startDate': startDate?.toIso8601String(),
        'startTime': startTime != null ? '${startTime!.hour}:${startTime!.minute}' : null,
        'endDate': endDate?.toIso8601String(),
        'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
        'reminders': reminders ? 1 : 0,
        'taken': taken ? 1 : 0,
      };

  factory Medicine.fromMap(Map<String, dynamic> m) {
    TimeOfDay? parseTime(String? s) {
      if (s == null) return null;
      final parts = s.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final mm = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: h, minute: mm);
    }

    return Medicine(
      id: m['id'] as int?,
      name: m['name'] ?? '',
      type: m['type'] ?? 'Tablet',
      strength: m['strength'] ?? '500 mg',
      imagePath: m['imagePath'],
      schedule: m['schedule'] ?? 'Every day',
      dosageFrequency: m['dosageFrequency'] ?? 'Once a day',
      startDate: m['startDate'] != null ? DateTime.parse(m['startDate']) : null,
      startTime: parseTime(m['startTime']),
      endDate: m['endDate'] != null ? DateTime.parse(m['endDate']) : null,
      endTime: parseTime(m['endTime']),
      reminders: (m['reminders'] ?? 0) == 1,
      taken: (m['taken'] ?? 0) == 1,
    );
  }
}