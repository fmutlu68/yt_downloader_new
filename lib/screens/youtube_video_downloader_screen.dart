import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader_updated/blocs/concrete/files/downloader/video_downloader_bloc.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/downloading_audio.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/downloading_video.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/youtube_video.dart';

class YoutubeVideoDownloaderScreen extends StatefulWidget {
  YoutubeVideo video;
  DownloaderState state;
  YoutubeVideoDownloaderScreen(this.video, this.state);
  @override
  _YoutubeVideoDownloaderScreenState createState() =>
      _YoutubeVideoDownloaderScreenState();
}

class _YoutubeVideoDownloaderScreenState
    extends State<YoutubeVideoDownloaderScreen> {
  TextStyle selectedTextStyle = const TextStyle(color: Colors.black);
  DownloadingVideo? _downloadingVideo;
  DownloadingAudio? _downloadingAudio;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (widget.state == DownloaderState.Audio) {
      _downloadingAudio = DownloadingAudio();
    } else {
      _downloadingVideo = DownloadingVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${widget.state == DownloaderState.Video ? "Video" : "Ses"} İndirme Ekranı"),
      ),
      floatingActionButton: getDownloadButton(),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
        child: buildListView(),
      ),
    );
  }

  Widget buildListView() {
    return widget.state == DownloaderState.Video
        ? buildVideoListView()
        : buildAudioListView();
  }

  Widget buildVideoListView() {
    return Platform.isAndroid || Platform.isFuchsia || Platform.isIOS
        ? ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildVideoNameWidget(),
              const SizedBox(height: 20),
              buildCategoryIdWidget(),
              const SizedBox(height: 20),
              buildVideoLinkWidget(),
              const SizedBox(height: 20),
              buildVideoDownloadingStateWidget(),
              const SizedBox(height: 20),
              buildVideoQualityWidget(),
              const SizedBox(height: 20),
              buildVideoStaticsWidget(),
              const SizedBox(height: 20),
              buildNameWidget(),
              const SizedBox(
                height: 20,
              ),
              buildVideoDownloaderStatusBar(),
            ],
          )
        : ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildTopFlexWidget(),
              const SizedBox(
                height: 20,
              ),
              buildCenterFlexWidget(),
              const SizedBox(
                height: 20,
              ),
              buildNameWidget(),
              const SizedBox(
                height: 20,
              ),
              buildVideoDownloaderStatusBar(),
            ],
          );
  }

  Widget buildAudioListView() {
    return Platform.isAndroid || Platform.isFuchsia || Platform.isIOS
        ? ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildVideoNameWidget(),
              const SizedBox(height: 20),
              buildCategoryIdWidget(),
              const SizedBox(height: 20),
              buildVideoLinkWidget(),
              const SizedBox(height: 20),
              buildVideoDownloadingStateWidget(),
              const SizedBox(height: 20),
              buildVideoStaticsWidget(),
              const SizedBox(height: 20),
              buildNameWidget(),
              const SizedBox(
                height: 20,
              ),
              buildVideoDownloaderStatusBar(),
            ],
          )
        : ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildTopFlexWidget(),
              const SizedBox(
                height: 20,
              ),
              buildCenterFlexWidget(),
              const SizedBox(
                height: 20,
              ),
              buildNameWidget(),
              const SizedBox(
                height: 20,
              ),
              buildVideoDownloaderStatusBar(),
            ],
          );
  }

  ListTile buildNameWidget() {
    return ListTile(
      tileColor: Colors.indigo,
      subtitle: const Text("Videonun İsmi --- Toplam Boyutu"),
      title: Text(widget.state == DownloaderState.Video
          ? (_downloadingVideo!.getSize.isEmpty
              ? _downloadingVideo!.getName
              : "${_downloadingVideo!.getName} --- ${_downloadingVideo!.getSize}")
          : (_downloadingAudio!.getSize.isEmpty
              ? _downloadingAudio!.getName
              : "${_downloadingAudio!.getName} --- ${_downloadingAudio!.getSize}")),
    );
  }

  LinearProgressIndicator buildVideoDownloaderStatusBar() {
    return LinearProgressIndicator(
      backgroundColor: Colors.brown,
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
      value: widget.state == DownloaderState.Video
          ? _downloadingVideo?.getStatus
          : _downloadingAudio?.getStatus,
      minHeight: 50,
    );
  }

  Flex buildCenterFlexWidget() {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: widget.state == DownloaderState.Video
          ? [
              Flexible(
                child: buildVideoDownloadingStateWidget(),
                flex: 3,
              ),
              const Flexible(
                child: SizedBox(
                  width: 20,
                ),
                flex: 1,
              ),
              Flexible(
                child: buildVideoQualityWidget(),
                flex: 3,
              ),
              const Flexible(
                child: const SizedBox(
                  width: 20,
                ),
                flex: 1,
              ),
              Flexible(
                child: buildVideoStaticsWidget(),
                flex: 3,
              ),
            ]
          : [
              Flexible(
                child: buildVideoDownloadingStateWidget(),
                flex: 3,
              ),
              const Flexible(
                child: SizedBox(
                  width: 20,
                ),
                flex: 1,
              ),
              Flexible(
                child: buildVideoStaticsWidget(),
                flex: 3,
              ),
            ],
    );
  }

  ListTile buildVideoStaticsWidget() {
    return ListTile(
      tileColor: Colors.deepPurple,
      title: Text(widget.state == DownloaderState.Video
          ? "%${(_downloadingVideo!.getStatus * 100).toInt()}"
          : "%${(_downloadingAudio!.getStatus * 100).toInt()}"),
      subtitle: Text(
          "${widget.state == DownloaderState.Video ? "Video" : "Ses"} Dosyasının İndirilme Yüzdeliği"),
    );
  }

  ListTile buildVideoQualityWidget() {
    return ListTile(
      tileColor: Colors.deepPurple,
      title: Text(_downloadingVideo!.getQuality),
      subtitle: const Text("Videonun Görüntü Kalitesi"),
    );
  }

  ListTile buildVideoDownloadingStateWidget() {
    return ListTile(
      tileColor: Colors.deepPurple,
      title: Text(widget.state == DownloaderState.Video
          ? _downloadingVideo!.getDownloadingState
          : _downloadingAudio!.getDownloadingState),
      subtitle: Text(
          "${widget.state == DownloaderState.Video ? "Video" : "Ses"} Dosyasının İndirilme Durumu"),
      trailing: widget.state == DownloaderState.Video
          ? _downloadingVideo!.getStatus > 0.0
              ? (_downloadingVideo!.getStatus < 1.0
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.download_done_outlined))
              : Icon(widget.video.videoIsDownloadedIcon)
          : _downloadingAudio!.getStatus > 0.0
              ? (_downloadingAudio!.getStatus < 1.0
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.download_done_outlined))
              : Icon(widget.video.audioIsDownloadedIcon),
    );
  }

  Flex buildTopFlexWidget() {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: buildVideoNameWidget(),
          flex: 3,
        ),
        const Flexible(
          child: SizedBox(
            width: 20,
          ),
          flex: 1,
        ),
        Flexible(
          child: buildCategoryIdWidget(),
          flex: 3,
        ),
        const Flexible(
          child: SizedBox(
            width: 20,
          ),
          flex: 1,
        ),
        Flexible(
          child: buildVideoLinkWidget(),
          flex: 3,
        ),
      ],
    );
  }

  buildVideoNameWidget() {
    return ListTile(
      tileColor: Colors.orange,
      title: Text(widget.video.name ?? "", style: selectedTextStyle),
      subtitle: Text("Video Adı", style: selectedTextStyle),
    );
  }

  buildCategoryIdWidget() {
    return ListTile(
      tileColor: Colors.orange,
      title: Text(widget.video.categoryId.toString(), style: selectedTextStyle),
      subtitle: Text("Videonun Kategori Numarası", style: selectedTextStyle),
    );
  }

  buildVideoLinkWidget() {
    return ListTile(
      tileColor: Colors.orange,
      title:
          Text(widget.video.youtubeVideoLink ?? "", style: selectedTextStyle),
      subtitle: Text("Videonun Youtube Linki", style: selectedTextStyle),
    );
  }

  getDownloadButton() {
    return FloatingActionButton(
      child: const Icon(Icons.download_rounded),
      tooltip:
          "${widget.state == DownloaderState.Video ? "Video" : "Ses"} İndirmeyi Başlat",
      onPressed: () {
        if (widget.state == DownloaderState.Video) {
          videoDownloaderBloc.downloadVideo(widget.video).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(
                  seconds: 4,
                ),
                content: Text(_downloadingVideo!.getDownloadingState),
              ),
            );
          });
          setState(() {
            _downloadingVideo = videoDownloaderBloc.getVideo;
          });
          settingState();
        } else {
          videoDownloaderBloc.downloadAudio(widget.video).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(
                  seconds: 4,
                ),
                content: Text(_downloadingAudio!.getDownloadingState),
              ),
            );
          });
          setState(() {
            _downloadingAudio = videoDownloaderBloc.getAudio;
          });
          settingState();
        }
      },
    );
  }

  void settingState() {
    if (widget.state == DownloaderState.Video) {
      if (_downloadingVideo?.getStatus != 1.0) {
        timer = Timer.periodic(
          const Duration(milliseconds: 50),
          (Timer t) => setState(() {
            if (_downloadingVideo?.getStatus == 1.0) {
              timer?.cancel();
            }
            _downloadingVideo = videoDownloaderBloc.getVideo;
          }),
        );
      } else {
        timer?.cancel();
      }
    } else {
      if (_downloadingAudio?.getStatus != 1.0) {
        timer = Timer.periodic(
          const Duration(milliseconds: 50),
          (Timer t) => setState(() {
            if (_downloadingAudio?.getStatus == 1.0) {
              timer?.cancel();
            }
            _downloadingAudio = videoDownloaderBloc.getAudio;
          }),
        );
      } else {
        timer?.cancel();
      }
    }
  }
}

enum DownloaderState { Video, Audio }
