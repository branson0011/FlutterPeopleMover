import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import 'base_repository.dart';

class CategoryRepository extends BaseRepository {
  static const String table = 'categories';

  Future<int> insertCategory(Category category) async {
    return await insert(table, category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final results = await query(table);
    return results.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Category>> getParentCategories() async {
    final results = await query(
      table,
      where: 'parent_id IS NULL',
    );
    return results.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Category>> getChildCategories(String parentId) async {
    final results = await query(
      table,
      where: 'parent_id = ?',
      whereArgs: [parentId],
    );
    return results.map((map) => Category.fromMap(map)).toList();
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
    final results = await this.query(
      table,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return results.map((map) => Category.fromMap(map)).toList();
  }
}
