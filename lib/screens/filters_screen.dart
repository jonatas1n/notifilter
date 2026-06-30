import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/theme/serene_focus_spacing.dart';
import '../models/emergency_settings.dart';
import '../models/filter_match_type.dart';
import '../models/filter_rule.dart';
import '../models/filter_rule_action.dart';
import '../providers/app_providers.dart';
import '../widgets/serene/serene_card.dart';
import '../widgets/serene/serene_section_header.dart';

class FiltersScreen extends ConsumerStatefulWidget {
  const FiltersScreen({super.key});

  @override
  ConsumerState<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  bool _appsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(filterRulesProvider);
    final emergencyAsync = ref.watch(emergencySettingsProvider);
    final inboxAsync = ref.watch(inboxProvider);

    return ListView(
      padding: const EdgeInsets.all(SereneFocusSpacing.marginMobile),
      children: [
        const SereneSectionHeader(
          title: 'Filter Configuration',
          subtitle: 'Palavras-chave prioritárias, proibidas e regras de emergência.',
        ),
        rulesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Erro: $error'),
          data: (rules) {
            final allowRules =
                rules.where((r) => r.action == FilterRuleAction.allow).toList();
            final blockRules =
                rules.where((r) => r.action == FilterRuleAction.block).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Prioritized keywords', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: SereneFocusSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...allowRules.map(
                      (rule) => InputChip(
                        label: Text(rule.keyword),
                        onDeleted: () => _deleteRule(rules, rule),
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                      onPressed: () => _addRule(context, rules, FilterRuleAction.allow),
                    ),
                  ],
                ),
                const SizedBox(height: SereneFocusSpacing.lg),
                Text('Prohibited keywords', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: SereneFocusSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...blockRules.map(
                      (rule) => InputChip(
                        label: Text(rule.keyword),
                        onDeleted: () => _deleteRule(rules, rule),
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                      onPressed: () => _addRule(context, rules, FilterRuleAction.block),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: SereneFocusSpacing.lg),
        SereneCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => setState(() => _appsExpanded = !_appsExpanded),
                child: Row(
                  children: [
                    Text(
                      'App Management',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Icon(_appsExpanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),
              if (_appsExpanded) ...[
                const SizedBox(height: SereneFocusSpacing.sm),
                inboxAsync.when(
                  loading: () => const Text('A carregar apps…'),
                  error: (_, __) => const Text('—'),
                  data: (items) {
                    final packages = items.map((e) => e.packageName).toSet().toList()
                      ..sort();
                    if (packages.isEmpty) {
                      return const Text('Nenhuma app interceptada ainda.');
                    }
                    return Column(
                      children: packages
                          .map(
                            (pkg) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(pkg),
                              trailing: const Icon(Icons.notifications_outlined),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: SereneFocusSpacing.lg),
        const SereneSectionHeader(title: 'Emergency Rules'),
        emergencyAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Text('Erro: $error'),
          data: (settings) => _EmergencyRulesCard(initial: settings),
        ),
      ],
    );
  }

  Future<void> _deleteRule(List<FilterRule> rules, FilterRule rule) async {
    final updated = rules.where((entry) => entry.id != rule.id).toList();
    await ref.read(filterRulesProvider.notifier).saveRules(updated);
  }

  Future<void> _addRule(
    BuildContext context,
    List<FilterRule> rules,
    FilterRuleAction action,
  ) async {
    final controller = TextEditingController();
    final keyword = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova palavra-chave'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Keyword'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (keyword == null || keyword.isEmpty) {
      return;
    }

    await ref.read(filterRulesProvider.notifier).saveRules([
      ...rules,
      FilterRule(
        id: const Uuid().v4(),
        keyword: keyword,
        matchType: FilterMatchType.contains,
        action: action,
      ),
    ]);
  }
}

class _EmergencyRulesCard extends ConsumerStatefulWidget {
  const _EmergencyRulesCard({required this.initial});

  final EmergencySettings initial;

  @override
  ConsumerState<_EmergencyRulesCard> createState() => _EmergencyRulesCardState();
}

class _EmergencyRulesCardState extends ConsumerState<_EmergencyRulesCard> {
  late int _attempts;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _attempts = widget.initial.thresholdCount;
    _minutes = widget.initial.windowMinutes;
  }

  @override
  void didUpdateWidget(covariant _EmergencyRulesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial.thresholdCount == widget.initial.thresholdCount &&
        oldWidget.initial.windowMinutes == widget.initial.windowMinutes) {
      return;
    }
    _attempts = widget.initial.thresholdCount;
    _minutes = widget.initial.windowMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return SereneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bypass if $_attempts attempts within $_minutes minutes',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Slider(
            value: _attempts.toDouble(),
            min: 2,
            max: 10,
            divisions: 8,
            label: '$_attempts',
            onChanged: (value) => setState(() => _attempts = value.round()),
          ),
          Slider(
            value: _minutes.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '$_minutes min',
            onChanged: (value) => setState(() => _minutes = value.round()),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () async {
                await ref.read(emergencySettingsProvider.notifier).saveSettings(
                      EmergencySettings(
                        thresholdCount: _attempts,
                        windowMinutes: _minutes,
                      ),
                    );
              },
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
