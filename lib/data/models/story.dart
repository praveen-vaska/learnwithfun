import 'package:equatable/equatable.dart';

class Story extends Equatable {
  final String id;
  final String title;
  final String moral;
  final String durationText;
  final String coverAsset;
  final String audioDuration;
  final List<String> pages;
  final bool isRhyme;
  final String language; // 'English', 'Telugu', 'Hindi'
  final bool hasVideo;
  final String videoTheme;
  final List<String> lyrics;
  final String? youtubeVideoId;
  final String? youtubeChannel;

  const Story({
    required this.id,
    required this.title,
    required this.moral,
    required this.durationText,
    required this.coverAsset,
    this.audioDuration = '02:30',
    required this.pages,
    this.isRhyme = false,
    this.language = 'English',
    this.hasVideo = false,
    this.videoTheme = 'general',
    this.lyrics = const [],
    this.youtubeVideoId,
    this.youtubeChannel,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    moral,
    durationText,
    coverAsset,
    audioDuration,
    pages,
    isRhyme,
    language,
    hasVideo,
    videoTheme,
    lyrics,
    youtubeVideoId,
    youtubeChannel,
  ];
}
