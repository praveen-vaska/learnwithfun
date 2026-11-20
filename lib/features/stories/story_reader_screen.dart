import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../blocs/stories_cubit.dart';
import 'kid_video_player_screen.dart';

class StoryReaderScreen extends StatelessWidget {
  const StoryReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storiesState = context.watch<StoriesCubit>().state;
    final story = storiesState.currentStory;

    if (story == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No story selected')),
      );
    }

    final currentPage = storiesState.currentPageIndex;
    final totalPages = story.pages.length;

    // Calculate simulated minutes:seconds
    final totalSeconds = 150; // 2m 30s
    final currentSeconds = (storiesState.playbackProgress * totalSeconds)
        .toInt();
    final curMin = (currentSeconds ~/ 60).toString().padLeft(2, '0');
    final curSec = (currentSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          story.title,
          style: AppTextStyles.heading2().copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            AppAudioService.instance.stop();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (story.hasVideo)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                  foregroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                ),
                onPressed: () {
                  AppAudioService.instance.stop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => KidVideoPlayerScreen(story: story),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.smart_display_rounded,
                  size: 18,
                  color: AppColors.primaryPurple,
                ),
                label: Text(
                  'Watch Video 🎬',
                  style: AppTextStyles.buttonSmall(
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // 1. Big Scenic Illustration Card
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AppVectorGraphic(
                    assetPath: story.coverAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Story Title & Moral
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Text(
                      story.title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading2(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      story.moral,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall(
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
              if (story.hasVideo) ...[
                const SizedBox(height: 10),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 250),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      AppAudioService.instance.stop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              KidVideoPlayerScreen(story: story),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.deepPurple,
                            AppColors.primaryPurple,
                            AppColors.pink,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.primaryPurple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.isRhyme
                                      ? 'Watch Animated Video & Sing Along! 🎬'
                                      : 'Watch Animated Story Video! 🎬',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  story.youtubeChannel != null
                                      ? 'Presented by ${story.youtubeChannel} 🎵'
                                      : 'Interactive fun animation for kids!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // 3. Story Content Box
              Expanded(
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: AppCard(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.softPurple,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Page ${currentPage + 1} of $totalPages',
                                  style: AppTextStyles.buttonSmall(
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      size: 20,
                                    ),
                                    onPressed: currentPage > 0
                                        ? () {
                                            context
                                                .read<StoriesCubit>()
                                                .previousPage();
                                            if (storiesState.isAudioPlaying) {
                                              AppAudioService.instance.speak(
                                                story.pages[currentPage - 1],
                                              );
                                            }
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                    onPressed: currentPage < totalPages - 1
                                        ? () {
                                            context
                                                .read<StoriesCubit>()
                                                .nextPage();
                                            if (storiesState.isAudioPlaying) {
                                              AppAudioService.instance.speak(
                                                story.pages[currentPage + 1],
                                              );
                                            }
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            story.pages[currentPage],
                            style: AppTextStyles.bodyLarge(
                              color: AppColors.textDark,
                            ).copyWith(height: 1.6, fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Interactive Audio Player Controls (Matching Reference Image)
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Time Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primaryPurple,
                          inactiveTrackColor: AppColors.softPurple,
                          thumbColor: AppColors.primaryPurple,
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                        ),
                        child: Slider(
                          value: storiesState.playbackProgress,
                          onChanged: (val) {
                            context.read<StoriesCubit>().setPlaybackProgress(
                              val,
                            );
                          },
                        ),
                      ),
                      // Time Stamps
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$curMin:$curSec',
                              style: AppTextStyles.bodySmall(
                                color: AppColors.textMedium,
                              ),
                            ),
                            Text(
                              story.audioDuration,
                              style: AppTextStyles.bodySmall(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Audio Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.replay_10_rounded,
                              color: AppColors.textDark,
                              size: 28,
                            ),
                            onPressed: () {
                              context.read<StoriesCubit>().setPlaybackProgress(
                                (storiesState.playbackProgress - 0.1).clamp(
                                  0.0,
                                  1.0,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              final wasPlaying = storiesState.isAudioPlaying;
                              context.read<StoriesCubit>().toggleAudio();
                              if (!wasPlaying) {
                                AppAudioService.instance.speak(
                                  story.pages[currentPage],
                                );
                              } else {
                                AppAudioService.instance.stop();
                              }
                            },
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryPurple,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                storiesState.isAudioPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(
                              Icons.forward_10_rounded,
                              color: AppColors.textDark,
                              size: 28,
                            ),
                            onPressed: () {
                              context.read<StoriesCubit>().setPlaybackProgress(
                                (storiesState.playbackProgress + 0.1).clamp(
                                  0.0,
                                  1.0,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
