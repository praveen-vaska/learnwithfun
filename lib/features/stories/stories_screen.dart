import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../blocs/stories_cubit.dart';
import '../../blocs/user_cubit.dart';
import '../../data/models/story.dart';
import 'story_reader_screen.dart';
import 'kid_video_player_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  bool _initializedWithUserLang = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedWithUserLang) {
      _initializedWithUserLang = true;
      final userProfile = context.read<UserCubit>().state;
      final storiesCubit = context.read<StoriesCubit>();

      // If stories cubit is currently on 'All' and user has a preferred language,
      // sync to the user's preferred language so they see their songs/stories immediately!
      if (storiesCubit.state.selectedLanguage == 'All' &&
          userProfile.language.isNotEmpty &&
          userProfile.language != 'English') {
        storiesCubit.setLanguage(userProfile.language);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storiesState = context.watch<StoriesCubit>().state;
    final stories = storiesState.stories;
    final activeFilter = storiesState.selectedFilter;
    final activeLanguage = storiesState.selectedLanguage;
    final userProfile = context.watch<UserCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Stories & Rhymes', style: AppTextStyles.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.softPurple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 14,
                  color: AppColors.primaryPurple,
                ),
                const SizedBox(width: 4),
                Text(
                  activeLanguage == 'All'
                      ? userProfile.language
                      : activeLanguage,
                  style: AppTextStyles.buttonSmall(
                    color: AppColors.primaryPurple,
                  ).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Language Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildLanguageChip(
                      label: 'All Languages',
                      langKey: 'All',
                      flagEmoji: '🌐',
                      isActive: activeLanguage == 'All',
                    ),
                    const SizedBox(width: 8),
                    _buildLanguageChip(
                      label: 'English',
                      langKey: 'English',
                      flagEmoji: '🇬🇧',
                      isActive: activeLanguage == 'English',
                    ),
                    const SizedBox(width: 8),
                    _buildLanguageChip(
                      label: 'Telugu (తెలుగు)',
                      langKey: 'Telugu',
                      flagEmoji: '🇮🇳',
                      isActive: activeLanguage == 'Telugu',
                    ),
                    const SizedBox(width: 8),
                    _buildLanguageChip(
                      label: 'Hindi (हिंदी)',
                      langKey: 'Hindi',
                      flagEmoji: '🇮🇳',
                      isActive: activeLanguage == 'Hindi',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Type Tabs (All, HD Videos, Stories, Rhymes)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.softPurple,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildFilterTab(
                      label: 'All',
                      filterKey: 'all',
                      isActive: activeFilter == 'all',
                    ),
                    _buildFilterTab(
                      label: '▶ Videos',
                      filterKey: 'videos',
                      isActive: activeFilter == 'videos',
                    ),
                    _buildFilterTab(
                      label: '📖 Stories',
                      filterKey: 'stories',
                      isActive: activeFilter == 'stories',
                    ),
                    _buildFilterTab(
                      label: '🎵 Rhymes',
                      filterKey: 'rhymes',
                      isActive: activeFilter == 'rhymes',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Featured Spotlight Card (shows when 'all' or 'videos' filter is active)
              if ((activeFilter == 'all' || activeFilter == 'videos') &&
                  stories.any((s) => s.hasVideo))
                _buildFeaturedSpotlight(stories.firstWhere((s) => s.hasVideo)),

              // 4. Stories & Rhymes List
              Expanded(
                child: stories.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: stories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = stories[index];
                          return FadeSlideIn(
                            delay: Duration(milliseconds: 60 * index),
                            child: _buildStoryCard(context, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageChip({
    required String label,
    required String langKey,
    required String flagEmoji,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<StoriesCubit>().setLanguage(langKey);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? AppColors.primaryPurple : AppColors.borderLight,
            width: 1.2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flagEmoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.buttonSmall(
                color: isActive ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required String filterKey,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<StoriesCubit>().setFilter(filterKey);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.heading3(
              color: isActive ? AppColors.primaryPurple : AppColors.textMedium,
            ).copyWith(fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSpotlight(Story featured) {
    final featuredVideoId = featured.youtubeVideoId ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => KidVideoPlayerScreen(story: featured),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6842E8), Color(0xFF7952F5), Color(0xFFFFB7CB)],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Real Video Thumbnail
              Container(
                width: 76,
                height: 66,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: featuredVideoId.isNotEmpty
                    ? Image.network(
                        'https://img.youtube.com/vi/$featuredVideoId/mqdefault.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            AppVectorGraphic(
                              assetPath: featured.coverAsset,
                              fit: BoxFit.cover,
                            ),
                      )
                    : AppVectorGraphic(
                        assetPath: featured.coverAsset,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'FEATURED SONG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      featured.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      featured.youtubeChannel != null
                          ? '${featured.youtubeChannel} • Sing along! 🎵'
                          : 'Tap to sing along now! 🎤',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Play button
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.primaryPurple,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, Story item) {
    final isVideo = item.hasVideo;
    final itemVideoId = item.youtubeVideoId ?? '';

    return AppCard(
      onTap: () {
        if (isVideo) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => KidVideoPlayerScreen(story: item),
            ),
          );
        } else {
          context.read<StoriesCubit>().openStory(item);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const StoryReaderScreen()),
          );
        }
      },
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Real Video Thumbnail (Clean, no red YouTube badge)
          Container(
            width: 74,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: (isVideo && itemVideoId.isNotEmpty)
                ? Image.network(
                    'https://img.youtube.com/vi/$itemVideoId/mqdefault.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        AppVectorGraphic(
                          assetPath: item.coverAsset,
                          fit: BoxFit.cover,
                        ),
                  )
                : AppVectorGraphic(
                    assetPath: item.coverAsset,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),

          // Title, Channel/Moral & Compact Tags
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.heading3().copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (item.youtubeChannel != null)
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.youtubeChannel!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 11,
                        color: AppColors.primaryPurple,
                      ),
                    ],
                  ),
                if (item.youtubeChannel == null)
                  Text(
                    item.moral,
                    style: AppTextStyles.bodySmall(color: AppColors.textMedium)
                        .copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),

                // Wrap to completely eliminate any overflow on any device
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Language Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softPurple,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.language == 'Telugu'
                            ? '🇮🇳 తెలుగు'
                            : item.language == 'Hindi'
                            ? '🇮🇳 हिंदी'
                            : '🇬🇧 English',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    // Duration
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          item.durationText.split('•').first.trim(),
                          style: AppTextStyles.bodySmall(
                            color: AppColors.textLight,
                          ).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Play action button (Child-friendly Soft Purple Circle)
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.softPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.primaryPurple,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: AppColors.softPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 46,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No items in this section yet!',
            style: AppTextStyles.heading2().copyWith(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            'Try switching language or category filters above.',
            style: AppTextStyles.bodySmall(color: AppColors.textMedium),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<StoriesCubit>().setLanguage('All');
              context.read<StoriesCubit>().setFilter('all');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Show All Stories & Rhymes'),
          ),
        ],
      ),
    );
  }
}
