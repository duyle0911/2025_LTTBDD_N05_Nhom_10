import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../l10n/l10n_ext.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  const BalanceCard({super.key, required this.balance});

  Color _accent(bool positive, ThemeData theme) => positive
      ? Colors.green
      : (balance == 0 ? theme.colorScheme.primary : Colors.redAccent);

  NumberFormat _currencyFmt(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.l10n;
    final isPositive = balance > 0;
    final accent = _accent(isPositive, theme);
    final fmt = _currencyFmt(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.10),
                theme.colorScheme.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                  child: Icon(
                    isPositive
                        ? Icons.trending_up_rounded
                        : (balance == 0
                            ? Icons.horizontal_rule_rounded
                            : Icons.trending_down_rounded),
                    color: accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.currentBalance,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fmt.format(balance),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPositive
                                      ? Icons.arrow_downward_rounded
                                      : (balance == 0
                                          ? Icons.remove
                                          : Icons.arrow_upward_rounded),
                                  size: 14,
                                  color: accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isPositive
                                      ? t.incomeGreater
                                      : (balance == 0
                                          ? t.incomeEqualsExpense
                                          : t.expenseGreater),
                                  style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: t.copyBalanceTooltip,
                  onPressed: () async {
                    final text = fmt.format(balance);
                    await Clipboard.setData(ClipboardData(text: text));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.copiedBalance(text))),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
