import '../models/category.dart';
import 'base_repository.dart';

class CategoryRepository extends BaseRepository {
  static const String table = 'categories';

  Future<int> insertCategory(Category category) async {
    return await insert(table, category.toMap());
  }

  Future<Category?> getCategory(String id) async {
    final maps = await query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<List<Category>> getAllCategories() async {
    final maps = await query(table);
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Category>> getChildCategories(String parentId) async {
    final maps = await query(
      table,
      where: 'parent_id = ?',
      whereArgs: [parentId],
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<void> updateCategory(Category category) async {
    await update(
      table,
      category.toMap(),
      'id = ?',
      [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    await delete(table, 'id = ?', [id]);
  }

  Future<List<Category>> searchCategories(String query) async {
    final maps = await this.query(
      table,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }
}
