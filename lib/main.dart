import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader_updated/screens/add_video_screen.dart';
import 'package:flutter_youtube_downloader_updated/screens/add_category_screen.dart';
import 'package:flutter_youtube_downloader_updated/screens/category_list_screen.dart';
import 'package:flutter_youtube_downloader_updated/screens/youtube_video_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(centerTitle: true),
        accentColor: Colors.black,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
      ),
      routes: {
        "/": (context) => new YoutubeVideoListScreen(),
        "/categories": (context) => new CategoryListScreen(),
        "/addVideo": (context) => new AddVideoScreen(),
        "/addCategory": (context) => new AddCategoryScreen(),
      },
      initialRoute: "/",
    );
  }
}
