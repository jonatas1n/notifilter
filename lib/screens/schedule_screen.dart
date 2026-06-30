import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/theme/serene_focus_spacing.dart';
import '../models/time_window.dart';
import '../providers/app_providers.dart';
import '../utils/time_window_weekdays.dart';
import '../widgets/serene/serene_card.dart';
import '../widgets/serene/serene_section_header.dart';
import '../widgets/time_window_editor.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int _selectedWeekday = DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    final quietAsync = ref.watch(quietSchedulesProvider);
    final digestAsync = ref.watch(digestWindowsProvider);
    final settingsAsync = ref.watch(appSettingsProvider);

    return ListView(
      padding: const EdgeInsets.all(SereneFocusSpacing.marginMobile),
      children: [
        const SereneSectionHeader(
          title: 'Quiet Times',
          subtitle: 'Weekly Routine — silencie notificações nos horários escolhidos.',
        ),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final weekday = index + 1;
            final selected = _selectedWeekday == weekday;
            return FilterChip(
              label: Text(_weekdayShort(weekday)),
              selected: selected,
              onSelected: (_) => setState(() => _selectedWeekday = weekday),
            );
          }),
        ),
        const SizedBox(height: SereneFocusSpacing.md),
        quietAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Text('Erro: $error'),
          data: (windows) => _RoutineList(
            selectedWeekday: _selectedWeekday,
            windows: windows.where((w) => w.weekdays.contains(_selectedWeekday)).toList(),
            onSave: (updated) {
              ref.read(quietSchedulesProvider.notifier).saveSchedules(updated);
            },
            allWindows: windows,
          ),
        ),
        const SizedBox(height: SereneFocusSpacing.xl),
        const SereneSectionHeader(title: 'Condensed Inbox'),
        settingsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (settings) {
            return SereneCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Permanent Mode'),
                subtitle: const Text(
                  'Retém tudo fora das janelas de entrega (digest).',
                ),
                value: settings.condensedInboxEnabled,
                onChanged: (enabled) async {
                  await ref.read(appSettingsProvider.notifier).saveSettings(
                        settings.copyWith(condensedInboxEnabled: enabled),
                      );
                },
              ),
            );
          },
        ),
        const SizedBox(height: SereneFocusSpacing.sm),
        Text('Delivery Windows', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: SereneFocusSpacing.sm),
        digestAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Text('Erro: $error'),
          data: (windows) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...windows.map(
                (window) => InputChip(
                  label: Text(
                    '${formatMinutesAsTime(window.startMinutes)}–'
                    '${formatMinutesAsTime(window.endMinutes)}',
                  ),
                  onDeleted: () {
                    final updated =
                        windows.where((w) => w.id != window.id).toList();
                    ref.read(digestWindowsProvider.notifier).saveWindows(updated);
                  },
                ),
              ),
              ActionChip(
                label: const Text('Add window'),
                onPressed: () async {
                  final created = await showTimeWindowEditor(context);
                  if (created == null) {
                    return;
                  }
                  ref.read(digestWindowsProvider.notifier).saveWindows([
                    ...windows,
                    TimeWindow(
                      id: const Uuid().v4(),
                      startMinutes: created.startMinutes,
                      endMinutes: created.endMinutes,
                      weekdays: created.weekdays,
                    ),
                  ]);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _weekdayShort(int weekday) {
    const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return labels[weekday - 1];
  }
}

class _RoutineList extends StatelessWidget {
  const _RoutineList({
    required this.selectedWeekday,
    required this.windows,
    required this.onSave,
    required this.allWindows,
  });

  final int selectedWeekday;
  final List<TimeWindow> windows;
  final List<TimeWindow> allWindows;
  final ValueChanged<List<TimeWindow>> onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...windows.map(
          (window) => Padding(
            padding: const EdgeInsets.only(bottom: SereneFocusSpacing.sm),
            child: SereneCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatMinutesAsTime(window.startMinutes)} – '
                      '${formatMinutesAsTime(window.endMinutes)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Switch(
                    value: true,
                    onChanged: (_) {
                      onSave(allWindows.where((w) => w.id != window.id).toList());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () async {
              final created = await showTimeWindowEditor(context);
              if (created == null) {
                return;
              }
              onSave([
                ...allWindows,
                TimeWindow(
                  id: const Uuid().v4(),
                  startMinutes: created.startMinutes,
                  endMinutes: created.endMinutes,
                  weekdays: mergeWeekdaySelection(
                    weekdays: created.weekdays,
                    selectedWeekday: selectedWeekday,
                  ),
                ),
              ]);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add rule'),
          ),
        ),
      ],
    );
  }
}
