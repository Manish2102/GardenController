
class ScheduledActivity {
  final String selectedTime;
  final int duration;
  final int frequency;
  final List<String> selectedDays;
  final int channel;

  ScheduledActivity({
    required this.selectedTime,
    required this.duration,
    required this.frequency,
    required this.selectedDays,
    required this.channel,
  });

  factory ScheduledActivity.fromJson(Map<String, dynamic> json) {
    return ScheduledActivity(
      selectedTime: json['selectedTime'],
      duration: json['duration'],
      frequency: json['frequency'] ?? 0, // Default to 0 if null
      selectedDays: List<String>.from(json['selectedDays'] ?? []),
      channel: json['channel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedTime': selectedTime,
      'duration': duration,
      'frequency': frequency,
      'selectedDays': selectedDays,
      'channel': channel,
    };
  }
}
