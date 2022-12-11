import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader_updated/blocs/concrete/database/sqflite/db_sqflite_category_bloc.dart';
import 'package:flutter_youtube_downloader_updated/blocs/concrete/database/sqflite/db_sqflite_youtube_video_bloc.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/category.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CategoryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kategori Listesi Ekranı"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: buildListViewFutureBuilder(),
      ),
    );
  }

  Widget buildListViewFutureBuilder() {
    return FutureBuilder<List<Category>>(
      initialData: [],
      future: loadCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: const CircularProgressIndicator());
        } else {
          return buildCategoryListViewItems(snapshot, context);
        }
      },
    );
  }

  Future<List<Category>> loadCategories() async {
    List<Category> categories = await dbSqfliteCategoryBloc.getAll();
    for (Category category in categories) {
      category.countHasVideo =
          (await dbSqfliteYoutubeVideoBloc.getAllByCategory(category.id ?? 0))
              .length;
    }
    for (Category category in categories) {
      category.countHasDownloadedVideo =
          (await dbSqfliteYoutubeVideoBloc.getAllByCategory(category.id ?? 0))
              .where((video) => video.isVideoDownloaded == true)
              .length;
    }
    for (Category category in categories) {
      category.countHasDownloadedAudio =
          (await dbSqfliteYoutubeVideoBloc.getAllByCategory(category.id ?? 0))
              .where((video) => video.isAudioDownloaded == true)
              .length;
    }
    return categories;
  }

  ListView buildCategoryListViewItems(
      AsyncSnapshot<List<Category>> snapshot, context) {
    return ListView.builder(
      itemCount: snapshot.data?.length ?? 0,
      itemBuilder: (context, index) {
        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                backgroundColor: Colors.red,
                foregroundColor: Colors.black,
                icon: Icons.delete,
                label: "Seçili Katgoriyi Sil",
                onPressed: (_) {
                  dbSqfliteCategoryBloc
                      .delete((snapshot.data ?? [])[index])
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                      duration: const Duration(seconds: 5),
                      content: Text(value),
                    ));
                  });
                },
              ),
            ],
          ),
          child: Card(
            color: Colors.deepPurple,
            child: buildCategoryTile((snapshot.data ?? [])[index], context),
          ),
        );
      },
    );
  }

  buildCategoryTile(Category category, context) {
    return ExpansionTile(
      leading: CircleAvatar(
        child: Text(
          category.id?.toString() ?? 0.toString(),
        ),
      ),
      title: Text(category.categoryName ?? ""),
      subtitle: Text(category.directoryPath ?? ""),
      children: [
        ListTile(
          tileColor: Colors.blueGrey,
          title: Text(category.categoryName ?? ""),
          subtitle: const Text("Kategori Adı"),
        ),
        ListTile(
          tileColor: Colors.blueGrey,
          title: Text(category.directoryPath ?? ""),
          subtitle: const Text("Kategori Klasörünün Konumu"),
          trailing: IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: "Klasörün Konumunu Kopyala",
            onPressed: () {
              FlutterClipboard.controlC(category.directoryPath ?? "")
                  .then((value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  new SnackBar(
                    duration: const Duration(seconds: 4),
                    content: const Text("Konum Kopyalandı."),
                  ),
                );
              });
            },
          ),
        ),
        ListTile(
          tileColor: Colors.blueGrey,
          title: Text(category.parentId == null
              ? "Yok"
              : "${category.parentId} Nolu Kategori"),
          subtitle: const Text("Kategorinin Üst Kategorisi"),
        ),
        ListTile(
          tileColor: Colors.blueGrey,
          title: Text(category.countHasVideo.toString()),
          subtitle: const Text("Kategoriye Kaydedilmiş Video Sayısı"),
        ),
        ListTile(
          tileColor: Colors.blueGrey,
          title: Text(category.countHasDownloadedVideo.toString()),
          subtitle:
              const Text("Kategoriye Ait İndirilmiş Video Dosyası Sayısı"),
        ),
        ListTile(
          tileColor: Colors.blueGrey,
          title: Text(category.countHasDownloadedAudio.toString()),
          subtitle:
              const Text("Kategoriye Ait İndirilmiş Sadece Ses Dosyası Sayısı"),
        ),
      ],
    );
  }
}
