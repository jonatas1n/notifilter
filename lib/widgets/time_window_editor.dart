import 'package:flutter/material.dart';

class TimeWindowDraft {
  const TimeWindowDraft({
    required this.startMinutes,
    required this.endMinutes,
    required this.weekdays,
  });

  final int startMinutes;
  final int endMinutes;
  final List<int> weekdays;
}

Future<TimeWindowDraft?> showTimeWindowEditor(BuildContext context) async {
  var start = const TimeOfDay(hour: 22, minute: 0);
  var end = const TimeOfDay(hour: 7, minute: 0);
  final weekdays = <int>{1, 2, 3, 4, 5};

  return showDialog<TimeWindowDraft>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Time window'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                ListTile(
                  title: const Text('Start'),
                  subtitle: Text(start.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: start,
                    );
                    if (picked == null) {
                      return;
                    }
                    setState(() => start = picked);
                  },
                ),
                ListTile(
                  title: const Text('End'),
                  subtitle: Text(end.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: end,
                    );
                    if (picked == null) {
                      return;
                    }
                    setState(() => end = picked);
                  },
                ),
                Wrap(
                  spacing: 4,
                  children: List.generate(7, (index) {
                    final weekday = index + 1;
                    final selected = weekdays.contains(weekday);
                    return FilterChip(
                      label: Text(_weekdayLabel(weekday)),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            weekdays.add(weekday);
                          } else {
                            weekdays.remove(weekday);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: weekdays.isEmpty
                    ? null
                    : () {
                        Navigator.pop(
                          context,
                          TimeWindowDraft(
                            startMinutes: start.hour * 60 + start.minute,
                            endMinutes: end.hour * 60 + end.minute,
                            weekdays: weekdays.toList()..sort(),
                          ),
                        );
                      },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

String _weekdayLabel(int weekday) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[weekday - 1];
}
