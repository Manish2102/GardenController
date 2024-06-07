class ScheduledActivity {
  final String selectedTime;
  final int duration;
  final int frequency;
  final List<String> selectedDays;

  ScheduledActivity({
    required this.selectedTime,
    required this.duration,
    required this.frequency,
    required this.selectedDays,
  });

  factory ScheduledActivity.fromJson(Map<String, dynamic> json) {
    return ScheduledActivity(
      selectedTime: json['selectedTime'],
      duration: json['duration'],
      frequency: json['frequency'],
      selectedDays: List<String>.from(json['selectedDays']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedTime': selectedTime,
      'duration': duration,
      'frequency': frequency,
      'selectedDays': selectedDays,
    };
  }
}
