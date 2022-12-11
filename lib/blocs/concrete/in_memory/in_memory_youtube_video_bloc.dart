import 'dart:async';

import 'package:flutter_youtube_downloader_updated/blocs/abstract/i_youtube_video_bloc.dart';
import 'package:flutter_youtube_downloader_updated/data/concrete/in_memory/in_memory_youtube_video_service.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/youtube_video.dart';

class InMemoryYoutubeVideoBloc implements IYoutubeVideoBloc {
  final _inMemoryYoutubeVideoStreamController = StreamController.broadcast();

  Stream get getStream => _inMemoryYoutubeVideoStreamController.stream;

  void addToVideos(YoutubeVideo video) {
    InMemoryYoutubeVideoService.addToVideos(video);
    _inMemoryYoutubeVideoStreamController.sink
        .add(InMemoryYoutubeVideoService.getAllVideos());
  }

  void updateFromVideos(YoutubeVideo video) {
    InMemoryYoutubeVideoService.updateFromVideos(video);
    _inMemoryYoutubeVideoStreamController.sink
        .add(InMemoryYoutubeVideoService.getAllVideos());
  }

  void removeFromVideos(YoutubeVideo video) {
    InMemoryYoutubeVideoService.removeFromVideos(video);
    _inMemoryYoutubeVideoStreamController.sink
        .add(InMemoryYoutubeVideoService.getAllVideos());
  }

  List<YoutubeVideo> getAllVideos() =>
      InMemoryYoutubeVideoService.getAllVideos();
}

final inMemoryYoutubeVideoBloc = new InMemoryYoutubeVideoBloc();
