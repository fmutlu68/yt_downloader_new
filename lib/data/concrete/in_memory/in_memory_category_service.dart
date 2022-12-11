import 'package:flutter_youtube_downloader_updated/data/abstract/icategory_service.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/category.dart';

class InMemoryCategoryService implements ICategoryService {
  static List<Category> categories = [];
  static InMemoryCategoryService _singleton =
      new InMemoryCategoryService._internal();

  factory InMemoryCategoryService() {
    return _singleton;
  }

  InMemoryCategoryService._internal();

  static void addToCategories(Category category) {
    categories.add(category);
  }

  static void removeFromCategories(Category category) {
    categories.add(category);
  }

  static void updateFromCategories(Category category) {
    Category updatedCategory =
        categories.firstWhere((element) => element.id == category.id);
    updatedCategory.categoryName = category.categoryName;
    updatedCategory.parentId = category.parentId;
  }

  static List<Category> getAllCategories() {
    categories.add(new Category(
      categoryName: "Deneme",
      id: 1,
    ));
    return categories;
  }
}
