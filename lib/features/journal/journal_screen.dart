import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/hijri_date.dart';
import '../../core/widgets/category_chip.dart';
import '../../data/models/journal_entry.dart';
import '../../l10n/l10n.dart';

/// سجل الحمد — the local-only journal (§6.4).
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final Set<int> _expanded = {};

  Future<void> _confirmDelete(JournalEntry entry) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEntryTitle),
        content: Text(l10n.deleteEntryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(journalRepositoryProvider).deleteEntry(entry.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entriesAsync = ref.watch(journalEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.journalTitle)),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            l10n.journalEmptyBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        data: (entries) => entries.isEmpty
            ? const _EmptyJournal()
            : ListView.separated(
                padding: const EdgeInsetsDirectional.all(20),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return _JournalCard(
                    entry: entry,
                    expanded: _expanded.contains(entry.id),
                    onTap: () => setState(() {
                      _expanded.contains(entry.id)
                          ? _expanded.remove(entry.id)
                          : _expanded.add(entry.id);
                    }),
                    onLongPress: () => _confirmDelete(entry),
                  );
                },
              ),
      ),
    );
  }
}

/// Journal card: surface + 16dp radius + a 3dp gold start-border (§6.4).
class _JournalCard extends StatelessWidget {
  const _JournalCard({
    required this.entry,
    required this.expanded,
    required this.onTap,
    required this.onLongPress,
  });

  final JournalEntry entry;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.alhamd;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            children: [
              PositionedDirectional(
                top: 0,
                bottom: 0,
                start: 0,
                width: 3,
                child: ColoredBox(color: colors.accent),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(19, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: CategoryChip(label: entry.blessingTitle)),
                        const SizedBox(width: 8),
                        Text(
                          HijriDateFormatter.formatHijri(entry.createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (entry.body.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        entry.body,
                        style: theme.textTheme.bodyMedium,
                        maxLines: expanded ? null : 3,
                        overflow: expanded ? null : TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyJournal extends StatelessWidget {
  const _EmptyJournal();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.alhamd;
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 56,
              color: colors.accent.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.journalEmptyBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                context.pop();
                context.push(AppRoutes.reflection);
              },
              child: Text(l10n.journalEmptyCta),
            ),
          ],
        ),
      ),
    );
  }
}
