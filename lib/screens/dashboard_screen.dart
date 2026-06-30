import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/serene_focus_colors.dart';
import '../core/theme/serene_focus_spacing.dart';
import '../models/contact_importance_level.dart';
import '../models/inbox_delivery_state.dart';
import '../models/notification_inbox_group.dart';
import '../models/time_window.dart';
import '../providers/app_providers.dart';
import '../utils/notification_grouper.dart';
import '../utils/schedule_evaluator.dart';
import '../widgets/serene/serene_card.dart';
import '../widgets/serene/serene_section_header.dart';
import '../widgets/serene/serene_stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(inboxGroupsProvider);
    final inboxAsync = ref.watch(inboxProvider);
    final importanceAsync = ref.watch(contactImportanceProvider);
    final quietAsync = ref.watch(quietSchedulesProvider);
    final settingsAsync = ref.watch(appSettingsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(inboxProvider.notifier).refreshInbox(),
      child: ListView(
        padding: const EdgeInsets.all(SereneFocusSpacing.marginMobile),
        children: [
          const SereneSectionHeader(
            title: 'Interceptadas Recentemente',
            subtitle: 'Controlo de importância por contacto e app.',
          ),
          const SizedBox(height: SereneFocusSpacing.md),
          inboxAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (items) {
              final filtered = countFilteredNotifications(items);
              final focused = countFocusedNotifications(items);
              return SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    SereneStatCard(
                      label: 'Filtradas',
                      value: '$filtered',
                      icon: Icons.filter_alt_outlined,
                    ),
                    const SizedBox(width: SereneFocusSpacing.sm),
                    SereneStatCard(
                      label: 'Focado',
                      value: '$focused',
                      icon: Icons.center_focus_strong_outlined,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: SereneFocusSpacing.lg),
          _SilenceModeCard(quietAsync: quietAsync),
          const SizedBox(height: SereneFocusSpacing.md),
          settingsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (settings) {
              if (settings.contactUnifySuggestionDismissed) {
                return const SizedBox.shrink();
              }
              return groupsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (groups) {
                  if (!shouldSuggestContactUnification(groups)) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: SereneFocusSpacing.md),
                    child: SereneCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unificar Contatos?',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: SereneFocusSpacing.xs),
                          Text(
                            'Detectámos o mesmo nome em apps diferentes. '
                            'A unificação completa chegará numa versão futura.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: SereneFocusSpacing.sm),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await ref
                                      .read(appSettingsProvider.notifier)
                                      .saveSettings(
                                        settings.copyWith(
                                          contactUnifySuggestionDismissed: true,
                                        ),
                                      );
                                },
                                child: const Text('Agora não'),
                              ),
                              const Spacer(),
                              FilledButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'TODO: unificação de contactos — ver design de agrupamento.',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Unificar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          groupsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Erro: $error'),
            data: (groups) {
              if (groups.isEmpty) {
                return SereneCard(
                  child: Text(
                    'Sem notificações interceptadas. '
                    'Conceda acesso ao listener para começar.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: groups.map((group) {
                  final level = importanceAsync.value?[group.groupKey] ??
                      ContactImportanceLevel.normal;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: SereneFocusSpacing.md),
                    child: _GroupNotificationCard(
                      group: group,
                      importanceLevel: level,
                      onImportanceChanged: (selected) {
                        ref
                            .read(contactImportanceProvider.notifier)
                            .setLevel(group.groupKey, selected);
                      },
                      onMarkRead: () async {
                        final latest = group.latestNotification;
                        if (latest?.id == null) {
                          return;
                        }
                        await ref
                            .read(inboxProvider.notifier)
                            .markAsRead(latest!.id!);
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SilenceModeCard extends StatelessWidget {
  const _SilenceModeCard({required this.quietAsync});

  final AsyncValue<List<TimeWindow>> quietAsync;

  @override
  Widget build(BuildContext context) {
    final isActive = quietAsync.maybeWhen(
      data: (windows) => isDateTimeWithinAnyTimeWindow(
        dateTime: DateTime.now(),
        windows: windows,
      ),
      orElse: () => false,
    );

    return SereneCard(
      child: Row(
        children: [
          Icon(
            isActive ? Icons.nightlight_round : Icons.wb_sunny_outlined,
            color: SereneFocusColors.primary,
          ),
          const SizedBox(width: SereneFocusSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo Silêncio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  isActive ? 'Ativo agora' : 'Inativo',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupNotificationCard extends StatelessWidget {
  const _GroupNotificationCard({
    required this.group,
    required this.importanceLevel,
    required this.onImportanceChanged,
    required this.onMarkRead,
  });

  final NotificationInboxGroup group;
  final ContactImportanceLevel importanceLevel;
  final ValueChanged<ContactImportanceLevel> onImportanceChanged;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat.Hm().format(
      DateTime.fromMillisecondsSinceEpoch(group.latestPostTime),
    );

    return SereneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SereneFocusColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  group.displayName.isNotEmpty
                      ? group.displayName[0].toUpperCase()
                      : '?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SereneFocusColors.primary,
                      ),
                ),
              ),
              const SizedBox(width: SereneFocusSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      group.packageName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(formattedTime, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: SereneFocusSpacing.sm),
          Text(
            group.previewText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (group.unreadCount > 1) ...[
            const SizedBox(height: SereneFocusSpacing.xs),
            Text(
              '${group.unreadCount} novas mensagens',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SereneFocusColors.primary,
                  ),
            ),
          ],
          if (group.latestNotification?.deliveryState ==
              InboxDeliveryState.delivered) ...[
            const SizedBox(height: SereneFocusSpacing.xs),
            Text(
              'Entregue no digest',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SereneFocusColors.success,
                  ),
            ),
          ],
          const SizedBox(height: SereneFocusSpacing.sm),
          DropdownButtonFormField<ContactImportanceLevel>(
            isExpanded: true,
            value: importanceLevel,
            decoration: const InputDecoration(
              labelText: 'Importância',
              isDense: true,
            ),
            items: ContactImportanceLevel.values
                .map(
                  (level) => DropdownMenuItem(
                    value: level,
                    child: Text(level.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              onImportanceChanged(value);
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onMarkRead, child: const Text('Marcar lida')),
          ),
        ],
      ),
    );
  }
}
