import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Small gold-tinted chip for the blessing category label («نعم الدين» …).
class CategoryChip extends StatelessWidget {
  const CategoryChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.alhamd;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.accent.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall!.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
