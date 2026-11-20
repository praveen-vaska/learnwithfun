import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_colors.dart';

class MatchPairLevel {
  final int levelNumber;
  final String title;
  final String theme;
  final String emoji;
  final String difficulty;
  final Color difficultyColor;
  final int timeSeconds;
  final int crossAxisCount;
  final List<Map<String, String>> pairs;

  const MatchPairLevel({
    required this.levelNumber,
    required this.title,
    required this.theme,
    required this.emoji,
    required this.difficulty,
    required this.difficultyColor,
    required this.timeSeconds,
    required this.crossAxisCount,
    required this.pairs,
  });

  int get pairCount => pairs.length;
  int get totalCards => pairCount * 2;

  static const List<MatchPairLevel> allLevels = [
    // Level 1: 2 pairs = 4 cards (2x2 grid)
    MatchPairLevel(
      levelNumber: 1,
      title: 'Baby Farm',
      theme: 'Farm Friends',
      emoji: '🐮',
      difficulty: 'Easy',
      difficultyColor: AppColors.green,
      timeSeconds: 35,
      crossAxisCount: 2,
      pairs: [
        {'asset': AssetPaths.animalCow, 'label': 'Cow'},
        {'asset': AssetPaths.animalCat, 'label': 'Cat'},
      ],
    ),

    // Level 2: 3 pairs = 6 cards (3x2 grid)
    MatchPairLevel(
      levelNumber: 2,
      title: 'Cute Pets',
      theme: 'Playful Pets',
      emoji: '🐶',
      difficulty: 'Easy',
      difficultyColor: AppColors.green,
      timeSeconds: 40,
      crossAxisCount: 3,
      pairs: [
        {'asset': AssetPaths.animalDog, 'label': 'Dog'},
        {'asset': AssetPaths.animalRabbit, 'label': 'Rabbit'},
        {'asset': AssetPaths.animalDuck, 'label': 'Duck'},
      ],
    ),

    // Level 3: 3 pairs = 6 cards (3x2 grid)
    MatchPairLevel(
      levelNumber: 3,
      title: 'Sweet Orchard',
      theme: 'Yummy Fruits',
      emoji: '🍎',
      difficulty: 'Easy',
      difficultyColor: AppColors.green,
      timeSeconds: 40,
      crossAxisCount: 3,
      pairs: [
        {'asset': AssetPaths.appleIllustration, 'label': 'Apple'},
        {'asset': AssetPaths.fruitBanana, 'label': 'Banana'},
        {'asset': AssetPaths.fruitMango, 'label': 'Mango'},
      ],
    ),

    // Level 4: 4 pairs = 8 cards (4x2 grid)
    MatchPairLevel(
      levelNumber: 4,
      title: 'Jungle Safari',
      theme: 'Wild Animals',
      emoji: '🦁',
      difficulty: 'Medium',
      difficultyColor: Color(0xFFF59E0B),
      timeSeconds: 45,
      crossAxisCount: 4,
      pairs: [
        {'asset': AssetPaths.animalLion, 'label': 'Lion'},
        {'asset': AssetPaths.animalPanda, 'label': 'Panda'},
        {'asset': AssetPaths.animalElephant, 'label': 'Elephant'},
        {'asset': AssetPaths.animalMonkey, 'label': 'Monkey'},
      ],
    ),

    // Level 5: 4 pairs = 8 cards (4x2 grid)
    MatchPairLevel(
      levelNumber: 5,
      title: 'Sky Flyers',
      theme: 'Beautiful Birds',
      emoji: '🦜',
      difficulty: 'Medium',
      difficultyColor: Color(0xFFF59E0B),
      timeSeconds: 45,
      crossAxisCount: 4,
      pairs: [
        {'asset': AssetPaths.birdParrot, 'label': 'Parrot'},
        {'asset': AssetPaths.birdOwl, 'label': 'Owl'},
        {'asset': AssetPaths.birdPeacock, 'label': 'Peacock'},
        {'asset': AssetPaths.birdFlamingo, 'label': 'Flamingo'},
      ],
    ),

    // Level 6: 5 pairs = 10 cards (3 or 4 cols)
    MatchPairLevel(
      levelNumber: 6,
      title: 'Shape Wonders',
      theme: 'Fun Shapes',
      emoji: '⭐',
      difficulty: 'Medium',
      difficultyColor: Color(0xFFF59E0B),
      timeSeconds: 50,
      crossAxisCount: 4,
      pairs: [
        {'asset': AssetPaths.shapeStar, 'label': 'Star'},
        {'asset': AssetPaths.shapeHeart, 'label': 'Heart'},
        {'asset': AssetPaths.shapeCircle, 'label': 'Circle'},
        {'asset': AssetPaths.shapeTriangle, 'label': 'Triangle'},
        {'asset': AssetPaths.shapeDiamond, 'label': 'Diamond'},
      ],
    ),

    // Level 7: 6 pairs = 12 cards (3x4 grid)
    MatchPairLevel(
      levelNumber: 7,
      title: 'Speed Wheels',
      theme: 'Cool Vehicles',
      emoji: '🚀',
      difficulty: 'Hard',
      difficultyColor: Color(0xFFEA580C),
      timeSeconds: 55,
      crossAxisCount: 3,
      pairs: [
        {'asset': AssetPaths.vehBus, 'label': 'Bus'},
        {'asset': AssetPaths.vehPlane, 'label': 'Plane'},
        {'asset': AssetPaths.vehTrain, 'label': 'Train'},
        {'asset': AssetPaths.vehBicycle, 'label': 'Bicycle'},
        {'asset': AssetPaths.vehFiretruck, 'label': 'Firetruck'},
        {'asset': AssetPaths.vehBoat, 'label': 'Boat'},
      ],
    ),

    // Level 8: 6 pairs = 12 cards (3x4 grid)
    MatchPairLevel(
      levelNumber: 8,
      title: 'Forest & Waves',
      theme: 'Friendly Creatures',
      emoji: '🐬',
      difficulty: 'Hard',
      difficultyColor: Color(0xFFEA580C),
      timeSeconds: 55,
      crossAxisCount: 3,
      pairs: [
        {'asset': AssetPaths.animalDolphin, 'label': 'Dolphin'},
        {'asset': AssetPaths.animalFrog, 'label': 'Frog'},
        {'asset': AssetPaths.animalSheep, 'label': 'Sheep'},
        {'asset': AssetPaths.animalHorse, 'label': 'Horse'},
        {'asset': AssetPaths.animalGiraffe, 'label': 'Giraffe'},
        {'asset': AssetPaths.animalBear, 'label': 'Bear'},
      ],
    ),

    // Level 9: 7 pairs = 14 cards (4 cols)
    MatchPairLevel(
      levelNumber: 9,
      title: 'Rainbow Forest',
      theme: 'Nature & Fruits',
      emoji: '🌈',
      difficulty: 'Hard',
      difficultyColor: Color(0xFFEA580C),
      timeSeconds: 60,
      crossAxisCount: 4,
      pairs: [
        {'asset': AssetPaths.sciSun, 'label': 'Sun'},
        {'asset': AssetPaths.sciRainbow, 'label': 'Rainbow'},
        {'asset': AssetPaths.fruitStrawberry, 'label': 'Strawberry'},
        {'asset': AssetPaths.fruitWatermelon, 'label': 'Watermelon'},
        {'asset': AssetPaths.fruitPineapple, 'label': 'Pineapple'},
        {'asset': AssetPaths.fruitOrange, 'label': 'Orange'},
        {'asset': AssetPaths.fruitCarrot, 'label': 'Carrot'},
      ],
    ),

    // Level 10: 8 pairs = 16 cards (4x4 Master Grid!)
    MatchPairLevel(
      levelNumber: 10,
      title: 'Grand Master Zoo',
      theme: 'All-Star Champions',
      emoji: '👑',
      difficulty: 'Master',
      difficultyColor: Color(0xFFDC2626),
      timeSeconds: 65,
      crossAxisCount: 4,
      pairs: [
        {'asset': AssetPaths.animalLion, 'label': 'Lion'},
        {'asset': AssetPaths.animalTiger, 'label': 'Tiger'},
        {'asset': AssetPaths.animalBear, 'label': 'Bear'},
        {'asset': AssetPaths.animalPanda, 'label': 'Panda'},
        {'asset': AssetPaths.animalElephant, 'label': 'Elephant'},
        {'asset': AssetPaths.animalGiraffe, 'label': 'Giraffe'},
        {'asset': AssetPaths.birdToucan, 'label': 'Toucan'},
        {'asset': AssetPaths.birdEagle, 'label': 'Eagle'},
      ],
    ),
  ];

  static MatchPairLevel getLevel(int levelNumber) {
    if (levelNumber < 1) return allLevels.first;
    if (levelNumber > allLevels.length) return allLevels.last;
    return allLevels[levelNumber - 1];
  }
}
