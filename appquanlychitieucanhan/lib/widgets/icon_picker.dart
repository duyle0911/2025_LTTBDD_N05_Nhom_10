import 'package:flutter/material.dart';
import '../models/category_icon_store.dart';

class IconChoice {
  final String name;
  final Color color;
  IconChoice(this.name, this.color);
}

/// [initialName], [initialColor]
/// [suggested]
Future<IconChoice?> pickIconChoice(
  BuildContext context, {
  String? initialName,
  Color? initialColor,
  List<String>? suggested,
}) {
  return showModalBottomSheet<IconChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final all = CategoryIconStore.iconCandidates;
      String search = '';
      String? currentName =
          initialName ?? (suggested?.firstOrNull ?? 'category');
      Color currentColor =
          initialColor ?? Theme.of(context).colorScheme.primary;

      final colorPalette = <Color>[
        const Color(0xFFEF5350),
        const Color(0xFFF06292),
        const Color(0xFFAB47BC),
        const Color(0xFF5C6BC0),
        const Color(0xFF42A5F5),
        const Color(0xFF26C6DA),
        const Color(0xFF26A69A),
        const Color(0xFF66BB6A),
        const Color(0xFFFFEE58),
        const Color(0xFFFFA726),
        const Color(0xFF8D6E63),
        const Color(0xFF78909C),
      ];

      List<String> filtered(List<String> source) {
        if (search.trim().isEmpty) return source;
        return source
            .where((n) => n.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }

      final suggestedList = suggested ?? const <String>[];
      return StatefulBuilder(
        builder: (ctx, setSt) {
          final list = [
            ...filtered(suggestedList).where((e) => !filtered(all).contains(e)),
            ...filtered(all),
          ];
          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Chọn biểu tượng & màu',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Tìm icon theo tên… (vd: coffee, shopping_cart)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (v) => setSt(() => search = v),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: colorPalette.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final c = colorPalette[i];
                      final sel = c.value == currentColor.value;
                      return InkWell(
                        onTap: () => setSt(() => currentColor = c),
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: sel ? Colors.black : Colors.white,
                                width: sel ? 2 : 1),
                          ),
                          child: sel
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 360,
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final name = list[i];
                      final icon =
                          CategoryIconStore.nameToIcon[name] ?? Icons.category;
                      final selected = currentName == name;
                      return InkWell(
                        onTap: () => setSt(() => currentName = name),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black12,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Center(child: Icon(icon, color: currentColor)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: currentName == null
                            ? null
                            : () => Navigator.pop(
                                ctx, IconChoice(currentName!, currentColor)),
                        child: const Text('Chọn'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Hủy'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

extension _FirstOrNullX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
