import 'package:shared_preferences/shared_preferences.dart';
import 'category_model.dart';

class CategoryService {
  static const String _categoriesKey = 'user_categories';
  static late SharedPreferences _prefs;

  // Initialize with pre-instantiated SharedPreferences
  static void init(SharedPreferences prefs) {
    _prefs = prefs;
  }

  static Future<List<Category>> getCategories() async {
    try {
      final List<String>? categoriesJson = _prefs.getStringList(_categoriesKey);
      if (categoriesJson == null) return [];

      return categoriesJson.map((json) {
        final parts = json.split('|');
        if (parts.length != 2) throw FormatException('Invalid category format');
        return Category(
          name: parts[0],
          balance: double.tryParse(parts[1]) ?? 0.0,
        );
      }).toList();
    } catch (e) {
      // Handle error and return empty list
      return [];
    }
  }

  static Future<bool> addCategory(Category category) async {
    try {
      final List<Category> existingCategories = await getCategories();
      existingCategories.add(category);

      final List<String> categoriesJson =
          existingCategories.map((cat) {
            return '${cat.name}|${cat.balance}';
          }).toList();

      return await _prefs.setStringList(_categoriesKey, categoriesJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateCategory(int index, Category newCategory) async {
    try {
      final List<Category> categories = await getCategories();
      if (index >= 0 && index < categories.length) {
        categories[index] = newCategory;
        return await _saveAllCategories(categories);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteCategory(int index) async {
    try {
      final List<Category> categories = await getCategories();
      if (index >= 0 && index < categories.length) {
        categories.removeAt(index);
        return await _saveAllCategories(categories);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _saveAllCategories(List<Category> categories) async {
    try {
      final List<String> categoriesJson =
          categories.map((cat) {
            return '${cat.name}|${cat.balance}';
          }).toList();

      return await _prefs.setStringList(_categoriesKey, categoriesJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearCategories() async {
    try {
      return await _prefs.remove(_categoriesKey);
    } catch (e) {
      return false;
    }
  }
}
