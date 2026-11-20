import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/category_tile.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/kid_animations.dart';
import '../../blocs/learning_cubit.dart';
import 'alphabet_grid_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<LearningCubit>().state.categories;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: canPop,
        title: Text('All Categories', style: AppTextStyles.heading2()),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              sliver: SliverToBoxAdapter(
                child: FadeSlideIn(
                  child: Text(
                    'Pick a world to explore today!',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.textMedium,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: categories.length,
                  (context, index) {
                    final cat = categories[index];
                    return PopIn(
                      delay: Duration(milliseconds: 80 + index * 70),
                      child: CategoryTile(
                        index: index,
                        title: cat.title,
                        subtitle: cat.subtitle,
                        assetPath: cat.assetPath,
                        palette: CategoryPalette.forId(cat.id, index),
                        progress: cat.progress,
                        onTap: () {
                          context.read<LearningCubit>().selectCategory(cat.id);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AlphabetGridScreen(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
