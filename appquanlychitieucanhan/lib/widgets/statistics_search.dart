import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';

class StatisticsSearch extends StatelessWidget {
  final TextEditingController controller;
  final String searchText;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final ValueChanged<String>? onSubmitted;
  final String? hint;

  const StatisticsSearch({
    super.key,
    required this.controller,
    required this.searchText,
    required this.onChanged,
    required this.onClear,
    this.onSubmitted,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.l10n;
    final effectiveHint = hint ?? t.searchHint;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Material(
        elevation: 1.5,
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surface,
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: effectiveHint,
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 1.2),
            ),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: searchText.isNotEmpty
                  ? IconButton(
                      key: const ValueKey('clear'),
                      tooltip: t.clearSearchTooltip,
                      icon: const Icon(Icons.clear),
                      onPressed: onClear,
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
        ),
      ),
    );
  }
}
