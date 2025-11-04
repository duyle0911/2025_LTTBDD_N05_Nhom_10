import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';

class TransactionSearch extends StatefulWidget {
  final TextEditingController controller;
  final String searchText;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final int debounceMs;
  final ValueChanged<String>? onSubmitted;
  final String? hint;

  const TransactionSearch({
    super.key,
    required this.controller,
    required this.searchText,
    required this.onChanged,
    required this.onClear,
    this.debounceMs = 0,
    this.onSubmitted,
    this.hint,
  });

  @override
  State<TransactionSearch> createState() => _TransactionSearchState();
}

class _TransactionSearchState extends State<TransactionSearch> {
  Timer? _debounce;

  void _handleChanged(String value) {
    if (widget.debounceMs <= 0) {
      widget.onChanged(value);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onChanged(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.l10n;
    final hintText = widget.hint ?? t.searchHint;
    final clearTooltip = t.clearSearchTooltip;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Material(
        elevation: 1.5,
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surface,
        child: TextField(
          controller: widget.controller,
          textInputAction: TextInputAction.search,
          onChanged: _handleChanged,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
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
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.2,
              ),
            ),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: widget.searchText.isNotEmpty
                  ? IconButton(
                      key: const ValueKey('clear'),
                      tooltip: clearTooltip,
                      icon: const Icon(Icons.clear),
                      onPressed: widget.onClear,
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
        ),
      ),
    );
  }
}
