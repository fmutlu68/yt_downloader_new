import 'dart:async';

import 'package:flutter_youtube_downloader_updated/blocs/abstract/i_category_bloc.dart';
import 'package:flutter_youtube_downloader_updated/data/concrete/in_memory/in_memory_category_service.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/category.dart';

class InMemoryCategoryBloc implements ICategoryBloc {
  final _inMemoryCategoryStreamController = StreamController.broadcast();

  Stream get getStream => _inMemoryCategoryStreamController.stream;

  void addToCategories(Category category) {
    InMemoryCategoryService.addToCategories(category);
    _inMemoryCategoryStreamController.sink
        .add(InMemoryCategoryService.getAllCategories());
  }

  void updateFromCategories(Category category) {
    InMemoryCategoryService.updateFromCategories(category);
    _inMemoryCategoryStreamController.sink
        .add(InMemoryCategoryService.getAllCategories());
  }

  void removeFromCategories(Category category) {
    InMemoryCategoryService.removeFromCategories(category);
    _inMemoryCategoryStreamController.sink
        .add(InMemoryCategoryService.getAllCategories());
  }

  List<Category> getAllCategories() =>
      InMemoryCategoryService.getAllCategories();
}

final inMemoryCategoryBloc = new InMemoryCategoryBloc();
