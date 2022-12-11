import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:cross_file/cross_file.dart';

import 'package:flutter_youtube_downloader_updated/blocs/concrete/database/sqflite/db_sqflite_youtube_video_bloc.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/youtube_video.dart';
import 'package:flutter_youtube_downloader_updated/screens/components/youtube_video_screen_components/navigation_drawer.dart';
import 'package:flutter_youtube_downloader_updated/screens/youtube_video_downloader_screen.dart';

class YoutubeVideoListScreen extends StatefulWidget {
  @override
  _YoutubeVideoListScreenState createState() => _YoutubeVideoListScreenState();
}

class _YoutubeVideoListScreenState extends State<YoutubeVideoListScreen> {
  Future<List<YoutubeVideo>>? _initialData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Videolar Listelendi."),
      ),
      floatingActionButton: buildGoToAddVideoScreenButton(context),
      body: buildVideoList(),
    );
  }

  buildVideoList() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: FutureBuilder(
        initialData: _initialData,
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Veriler Çekiliyor. Lütfen Bekleyiniz..."),
                CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ),
              ],
            ));
          } else {
            return ((snapshot.data as List?) ?? []).length > 0
                ? buildVideoListItems(snapshot.data)
                : Center(child: Text("Herhangi Bir Video Bulunamadı."));
          }
        },
      ),
    );
  }

  buildVideoListItems(var videos) {
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 8, left: 8, bottom: 15),
          child: buildSlidableWidget(videos, index),
        );
      },
    );
  }

  Slidable buildSlidableWidget(List<YoutubeVideo> list, int index) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              await goToSelectedYoutubeVideoScreen(
                  list[index].isVideoDownloaded ?? false,
                  list[index].isAudioDownloaded ?? false,
                  list[index],
                  DownloaderState.Audio);
            },
            backgroundColor: Colors.blue,
            icon: list[index].audioIsDownloadedIcon,
            foregroundColor: Colors.black,
            label: list[index].audioIsDownloadedIcon ==
                    Icons.ondemand_video_outlined
                ? "Sesini Dinle"
                : "Sesini İndir",
          ),
          SlidableAction(
            onPressed: (_) async {
              await goToSelectedYoutubeVideoScreen(
                  list[index].isVideoDownloaded ?? false,
                  list[index].isAudioDownloaded ?? false,
                  list[index],
                  DownloaderState.Video);
            },
            backgroundColor: Colors.blue,
            icon: list[index].videoIsDownloadedIcon,
            foregroundColor: Colors.black,
            label: list[index].videoIsDownloadedIcon ==
                    Icons.ondemand_video_outlined
                ? "Videoyu İzle"
                : "Videoyu İndir",
          )
        ],
      ),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.red,
            icon: Icons.delete,
            onPressed: (_) {
              dbSqfliteYoutubeVideoBloc.delete(list[index]).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(value),
                ));
                getData();
              });
            },
            foregroundColor: Colors.black,
            label: "Sil",
          ),
        ],
      ),
      child: ListTile(
        onLongPress: () async {
          if (list[index].videoPath == null ||
              (list[index].videoPath?.isEmpty ?? true)) return;
          await Share.shareXFiles([XFile(list[index].videoPath!)]);
        },
        trailing: Icon(list[index].videoIsDownloadedIcon),
        subtitle: Text(
            "Video İndirildi Mi: ${list[index].isVideoDownloaded == true ? "Evet" : "Hayır"}\nSes Dosyası İndirildi Mi: ${list[index].isAudioDownloaded == true ? "Evet" : "Hayır"}",
            style: TextStyle(color: Colors.black)),
        tileColor: Colors.orange,
        title:
            Text(list[index].name ?? "", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  buildGoToAddVideoScreenButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        goToAddVideoScreen(context);
      },
    );
  }

  goToAddVideoScreen(BuildContext context) async {
    await Navigator.pushNamed(context, "/addVideo");
    getData();
  }

  Future<List<YoutubeVideo>> getData() async {
    _initialData = dbSqfliteYoutubeVideoBloc.getAll();
    setState(() {});
    return _initialData == null
        ? await dbSqfliteYoutubeVideoBloc.getAll()
        : await _initialData!;
  }

  goToSelectedYoutubeVideoScreen(bool isVideoDownloaded, bool isAudioDownloaded,
      YoutubeVideo video, DownloaderState downloaderState) {
    if (downloaderState == DownloaderState.Video) {
      if (isVideoDownloaded == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (cont) =>
                YoutubeVideoDownloaderScreen(video, downloaderState),
          ),
        ).then((value) {
          getData();
        });
      } else {
        OpenFile.open(
          video.videoPath,
        );
      }
    } else {
      if (isAudioDownloaded == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (cont) =>
                YoutubeVideoDownloaderScreen(video, downloaderState),
          ),
        ).then((value) {
          getData();
        });
      } else {
        OpenFile.open(
          video.musicPath,
        );
      }
    }
  }
}
