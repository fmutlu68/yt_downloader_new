import 'dart:io';
import 'dart:math';

import 'package:flutter_youtube_downloader_updated/blocs/concrete/database/sqflite/db_sqflite_category_bloc.dart';
import 'package:flutter_youtube_downloader_updated/blocs/concrete/database/sqflite/db_sqflite_youtube_video_bloc.dart';
import 'package:flutter_youtube_downloader_updated/data/abstract/ivideo_downloader_service.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/category.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/downloading_audio.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/downloading_video.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/youtube_video.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloaderService implements IVideoDownloaderService {
  DownloadingVideo _downloadingVideo = DownloadingVideo();
  DownloadingVideo get getVideo => _downloadingVideo;

  DownloadingAudio _downloadingAudio = DownloadingAudio();
  DownloadingAudio get getAudio => _downloadingAudio;

  YoutubeExplode youtubeExplode = YoutubeExplode();
  Category? videoCategory;

  static final DownloaderService _singleton = DownloaderService._internal();

  factory DownloaderService() {
    return _singleton;
  }

  DownloaderService._internal();

  Future<void> downloadVideo(YoutubeVideo video) async {
    _downloadingVideo = DownloadingVideo();
    _downloadingVideo.setQuality = "Bir Dakika...";
    _downloadingVideo.setDownloadingState =
        "Video İndirme İşlemi Başlatıldı...";
    videoCategory = await dbSqfliteCategoryBloc.getById(video.categoryId ?? 0);
    video.youtubeVideoLink?.trim();
    var manifest = await youtubeExplode.videos.streamsClient
        .getManifest(video.youtubeVideoLink);
    _downloadingVideo.setDownloadingState =
        "Video Hakkında Bilgi Toplanıyor...";
    var streams = manifest.muxed
        .where((element) => element.videoQualityLabel == "1080p60");
    _downloadingVideo.setQuality = "UHD 1080p 60 fps";
    if (streams.isEmpty || streams == null) {
      streams = manifest.muxed
          .where((element) => element.videoQualityLabel == "1080p");
      _downloadingVideo.setQuality = "HD 1080p";
    }
    if (streams.isEmpty || streams == null) {
      streams = manifest.muxed
          .where((element) => element.videoQualityLabel == "720p");
      _downloadingVideo.setQuality = "HD 720p";
    }
    if (streams == null || streams.isEmpty) {
      streams = manifest.muxed;
      _downloadingVideo.setQuality = "SD 360p";
    }

    _downloadingVideo.setDownloadingState = "Video Dosyası Hazırlanıyor...";
    var audio = streams.withHighestBitrate();
    var audioStream = youtubeExplode.videos.streamsClient.get(audio);
    var fileName = '${video.name}.${audio.container.name.toString()}'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .replaceAll('|', '')
        .replaceAll("#", "sharp");
    _downloadingVideo.setName = fileName;
    _downloadingVideo.setDownloadingState = "Video Dosyası Oluşturuluyor...";
    var file = File(
        "${videoCategory?.directoryPath?.replaceAll(r"\", "/")}/$fileName");
    if (file.existsSync()) {
      file.deleteSync();
    }
    var output = file.openWrite(mode: FileMode.writeOnlyAppend);

    double len = audio.size.totalBytes.toDouble();
    double count = 0;

    _downloadingVideo.setDownloadingState = "Video İndiriliyor...";
    int allData = 0;
    await for (var data in audioStream) {
      allData += data.length;
      count += data.length.toDouble();
      double progress = ((count / len) / 1);
      _downloadingVideo.setStatus = progress;
      output.add(data);
    }
    _downloadingVideo.setSize = getSize(allData, 1);
    _downloadingVideo.setDownloadingState = "Video İndirme İşlemi Başarılı.";
    _downloadingVideo.setPath = file.path;
    video.videoPath = file.path;
    video.videoQuality = _downloadingVideo.getQuality;
    dbSqfliteYoutubeVideoBloc.update(video);
  }

  Future<void> downloadOnlyAudio(YoutubeVideo video) async {
    _downloadingAudio = DownloadingAudio();
    _downloadingVideo.setDownloadingState =
        "Sadece Ses İndirme İşlemi Başlatldı...";
    videoCategory = await dbSqfliteCategoryBloc.getById(video.categoryId ?? 0);
    if (videoCategory != null) {
      Directory(videoCategory!.directoryPath!).createSync();
    }
    video.youtubeVideoLink?.trim();

    StreamManifest manifest = await youtubeExplode.videos.streamsClient
        .getManifest(video.youtubeVideoLink);
    _downloadingAudio.setDownloadingState =
        "Video Hakkında Bilgi Toplanıyor...";
    Iterable<AudioOnlyStreamInfo> streams = manifest.audioOnly;

    var audio = streams.withHighestBitrate();
    var audioStream = youtubeExplode.videos.streamsClient.get(audio);

    _downloadingAudio.setDownloadingState = "Ses Dosyası Hazırlanıyor...";

    var fileName = '${video.name}.${audio.container.name.toString()}'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll("(", " ")
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '')
        .replaceAll("(", " ")
        .replaceAll(")", " ")
        .replaceAll("#", "sharp");
    _downloadingAudio.setName = fileName;
    _downloadingAudio.setDownloadingState = "Ses Dosyası Oluşturuluyor...";
    var file = File('${videoCategory?.directoryPath}/$fileName');

    if (file.existsSync()) {
      file.deleteSync();
    }
    var output = file.openWrite(mode: FileMode.writeOnlyAppend);

    double len = audio.size.totalBytes.toDouble();
    double count = 0;

    _downloadingAudio.setDownloadingState = "Ses İndiriliyor...";

    await for (var data in audioStream) {
      count += data.length.toDouble();

      double progress = ((count / len) / 1);

      _downloadingAudio.setStatus = progress;

      output.add(data);
    }
    _downloadingAudio.setSize = getSize(file.lengthSync(), 1);
    _downloadingAudio.setDownloadingState = "Ses İndirilme İşlemi Başarılı.";
    _downloadingAudio.setPath = file.path;
    video.musicPath = file.path;
    dbSqfliteYoutubeVideoBloc.update(video);
  }

  getSize(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    print(
        ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i]);
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }
}
