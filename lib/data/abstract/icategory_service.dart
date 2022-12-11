import 'package:flutter_youtube_downloader_updated/models/concrete/category.dart';

import 'i_service.dart';

abstract class ICategoryService implements IService {
  static void addToCategories(Category category) {}

  static void removeFromCategories(Category category) {}

  static void updateFromCategories(Category category) {}

  static List<Category> getAllCategories() => [];
}
