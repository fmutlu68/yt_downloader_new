import 'package:flutter_youtube_downloader_updated/data/abstract/i_service.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/youtube_video.dart';

abstract class IYoutubeVideoService implements IService {
  static void addToVideos(YoutubeVideo video) {}
  static void removeFromVideos(YoutubeVideo video) {}
  static void updateFromVideos(YoutubeVideo video) {}
  static List<YoutubeVideo> getAllVideos() => [];
}
