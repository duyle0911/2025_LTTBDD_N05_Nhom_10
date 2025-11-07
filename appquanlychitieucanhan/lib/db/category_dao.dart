import 'package:sqflite/sqflite.dart';
import 'app_db.dart';

class CategoryDto {
  final String id;
  final String name;
  final String type;
  final String? icon;
  final String? colorHex;

  CategoryDto({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.colorHex,
  });

  factory CategoryDto.fromMap(Map<String, Object?> m) => CategoryDto(
        id: m['id'] as String,
        name: m['name'] as String,
        type: m['type'] as String,
        icon: m['icon'] as String?,
        colorHex: m['color_hex'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'icon': icon,
        'color_hex': colorHex,
      };
}

class CategoryDao {
  Future<Database> get _db async => AppDatabase().database;

  Future<List<CategoryDto>> getByType(String type) async {
    final db = await _db;
    final rows = await db.query('categories',
        where: 'type = ?', whereArgs: [type], orderBy: 'name ASC');
    return rows.map(CategoryDto.fromMap).toList();
  }

  Future<void> upsert(CategoryDto c) async {
    final db = await _db;
    await db.insert('categories', c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> rename(String id, String newName) async {
    final db = await _db;
    await db.update('categories', {'name': newName},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> remove(String id) async {
    final db = await _db;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
