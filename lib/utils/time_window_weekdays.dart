List<int> mergeWeekdaySelection({
  required List<int> weekdays,
  required int selectedWeekday,
}) {
  if (weekdays.contains(selectedWeekday)) {
    return List<int>.from(weekdays)..sort();
  }

  return [...weekdays, selectedWeekday]..sort();
}
