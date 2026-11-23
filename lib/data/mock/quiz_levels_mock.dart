import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_colors.dart';
import '../models/quiz_level.dart';
import '../models/quiz_question.dart';

class QuizLevelsMock {
  QuizLevelsMock._();

  static const List<QuizLevel> levels = [
    // ==========================================
    // LEVEL 1: VERY EASY - Farmyard Babies
    // ==========================================
    QuizLevel(
      levelNumber: 1,
      title: 'Farmyard Babies',
      subtitle: 'Gentle barn animals and familiar pets',
      difficulty: 'Very Easy',
      themeColor: AppColors.green,
      icon: Icons.pets_rounded,
      xpReward: 30,
      questions: [
        QuizQuestion(
          id: 'l1_q1',
          questionText: 'Which animal says...?',
          illustrationAsset: AssetPaths.animalCow,
          humanPrompt: 'Which animal says...',
          animalSound: 'cow',
          soundDescription: 'Moo 🐄',
          difficulty: 'Very Easy',
          funFact: 'Cows love eating fresh green grass and produce yummy milk!',
          correctOptionIndex: 0,
          options: [
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l1_q2',
          questionText: 'Which loyal friend says...?',
          illustrationAsset: AssetPaths.animalDog,
          humanPrompt: 'Which loyal friend says...',
          animalSound: 'dog',
          soundDescription: 'Woof Woof 🐕',
          difficulty: 'Very Easy',
          funFact: 'Dogs wag their tails back and forth when they are happy!',
          correctOptionIndex: 0,
          options: [
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
            QuizOption(
              label: 'Sheep',
              illustrationAsset: AssetPaths.animalSheep,
              animalSound: 'sheep',
            ),
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l1_q3',
          questionText: 'Which sweet furry pet says...?',
          illustrationAsset: AssetPaths.animalCat,
          humanPrompt: 'Which sweet furry pet says...',
          animalSound: 'cat',
          soundDescription: 'Meow 🐱',
          difficulty: 'Very Easy',
          funFact: 'Cats purr gently when you pet their soft fur!',
          correctOptionIndex: 1,
          options: [
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Bird',
              illustrationAsset: AssetPaths.birdSparrow,
              animalSound: 'bird',
            ),
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l1_q4',
          questionText: 'Which swimming bird says...?',
          illustrationAsset: AssetPaths.animalDuck,
          humanPrompt: 'Which swimming bird says...',
          animalSound: 'duck',
          soundDescription: 'Quack Quack 🦆',
          difficulty: 'Very Easy',
          funFact: 'Ducks have webbed feet that paddle like little oars in water!',
          correctOptionIndex: 2,
          options: [
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
            QuizOption(
              label: 'Frog',
              illustrationAsset: AssetPaths.animalFrog,
              animalSound: 'frog',
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // LEVEL 2: VERY EASY - Barnyard Choirs
    // ==========================================
    QuizLevel(
      levelNumber: 2,
      title: 'Barnyard Choirs',
      subtitle: 'Woolly friends and early morning callers',
      difficulty: 'Very Easy',
      themeColor: Color(0xFF38BDF8),
      icon: Icons.music_note_rounded,
      xpReward: 35,
      questions: [
        QuizQuestion(
          id: 'l2_q1',
          questionText: 'Which woolly friend says...?',
          illustrationAsset: AssetPaths.animalSheep,
          humanPrompt: 'Which woolly friend says...',
          animalSound: 'sheep',
          soundDescription: 'Baa Baa 🐑',
          difficulty: 'Very Easy',
          funFact: 'Sheep have thick fluffy wool that keeps them warm in the winter!',
          correctOptionIndex: 0,
          options: [
            QuizOption(
              label: 'Sheep',
              illustrationAsset: AssetPaths.animalSheep,
              animalSound: 'sheep',
            ),
            QuizOption(
              label: 'Horse',
              illustrationAsset: AssetPaths.animalHorse,
              animalSound: 'horse',
            ),
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l2_q2',
          questionText: 'Who wakes the farm with...?',
          illustrationAsset: AssetPaths.animalRooster,
          humanPrompt: 'Who wakes the farm with...',
          animalSound: 'rooster',
          soundDescription: 'Cock-a-doodle-doo 🐓',
          difficulty: 'Very Easy',
          funFact: 'Roosters crow right as the golden morning sun peeks over the hills!',
          correctOptionIndex: 1,
          options: [
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
            QuizOption(
              label: 'Rooster',
              illustrationAsset: AssetPaths.animalRooster,
              animalSound: 'rooster',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Owl',
              illustrationAsset: AssetPaths.birdOwl,
              animalSound: 'owl',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l2_q3',
          questionText: 'Which galloping friend says...?',
          illustrationAsset: AssetPaths.animalHorse,
          humanPrompt: 'Which galloping friend says...',
          animalSound: 'horse',
          soundDescription: 'Neigh Neigh 🐴',
          difficulty: 'Very Easy',
          funFact: 'Horses can run very fast and can even sleep while standing up!',
          correctOptionIndex: 2,
          options: [
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
            QuizOption(
              label: 'Sheep',
              illustrationAsset: AssetPaths.animalSheep,
              animalSound: 'sheep',
            ),
            QuizOption(
              label: 'Horse',
              illustrationAsset: AssetPaths.animalHorse,
              animalSound: 'horse',
            ),
            QuizOption(
              label: 'Lion',
              illustrationAsset: AssetPaths.animalLion,
              animalSound: 'lion',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l2_q4',
          questionText: 'Which little songbird says...?',
          illustrationAsset: AssetPaths.birdSparrow,
          humanPrompt: 'Which little songbird says...',
          animalSound: 'bird',
          soundDescription: 'Chirp Chirp 🐦',
          difficulty: 'Very Easy',
          funFact: 'Songbirds sing joyful melodies from treetop branches!',
          correctOptionIndex: 3,
          options: [
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Bird',
              illustrationAsset: AssetPaths.birdSparrow,
              animalSound: 'bird',
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // LEVEL 3: EASY - Wild Safari
    // ==========================================
    QuizLevel(
      levelNumber: 3,
      title: 'Wild Safari',
      subtitle: 'Big cats, gentle giants, and jungle jumpers',
      difficulty: 'Easy',
      themeColor: Color(0xFFF59E0B),
      icon: Icons.explore_rounded,
      xpReward: 40,
      questions: [
        QuizQuestion(
          id: 'l3_q1',
          questionText: 'Which King of the Jungle says...?',
          illustrationAsset: AssetPaths.animalLion,
          humanPrompt: 'Which King of the Jungle says...',
          animalSound: 'lion',
          soundDescription: 'Roar 🦁',
          difficulty: 'Easy',
          funFact: 'A lion’s mighty roar can be heard from miles across the savanna!',
          correctOptionIndex: 0,
          options: [
            QuizOption(
              label: 'Lion',
              illustrationAsset: AssetPaths.animalLion,
              animalSound: 'lion',
            ),
            QuizOption(
              label: 'Monkey',
              illustrationAsset: AssetPaths.animalMonkey,
              animalSound: 'monkey',
            ),
            QuizOption(
              label: 'Elephant',
              illustrationAsset: AssetPaths.animalElephant,
              animalSound: 'elephant',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l3_q2',
          questionText: 'Which giant trunked friend says...?',
          illustrationAsset: AssetPaths.animalElephant,
          humanPrompt: 'Which giant trunked friend says...',
          animalSound: 'elephant',
          soundDescription: 'Trumpet 🐘',
          difficulty: 'Easy',
          funFact: 'Elephants use their long trunks to spray water and pick up tasty fruit!',
          correctOptionIndex: 1,
          options: [
            QuizOption(
              label: 'Horse',
              illustrationAsset: AssetPaths.animalHorse,
              animalSound: 'horse',
            ),
            QuizOption(
              label: 'Elephant',
              illustrationAsset: AssetPaths.animalElephant,
              animalSound: 'elephant',
            ),
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
            QuizOption(
              label: 'Sheep',
              illustrationAsset: AssetPaths.animalSheep,
              animalSound: 'sheep',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l3_q3',
          questionText: 'Who hops by the pond and says...?',
          illustrationAsset: AssetPaths.animalFrog,
          humanPrompt: 'Who hops by the pond and says...',
          animalSound: 'frog',
          soundDescription: 'Ribbit Ribbit 🐸',
          difficulty: 'Easy',
          funFact: 'Frogs have long sticky tongues to catch pesky bugs mid-air!',
          correctOptionIndex: 2,
          options: [
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
            QuizOption(
              label: 'Bird',
              illustrationAsset: AssetPaths.birdSparrow,
              animalSound: 'bird',
            ),
            QuizOption(
              label: 'Frog',
              illustrationAsset: AssetPaths.animalFrog,
              animalSound: 'frog',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l3_q4',
          questionText: 'Who swings from branch to branch and says...?',
          illustrationAsset: AssetPaths.animalMonkey,
          humanPrompt: 'Who swings from branch to branch and says...',
          animalSound: 'monkey',
          soundDescription: 'Ooh-Ooh Aah-Aah 🐵',
          difficulty: 'Easy',
          funFact: 'Monkeys use their strong tails to hold onto tree limbs like an extra hand!',
          correctOptionIndex: 3,
          options: [
            QuizOption(
              label: 'Lion',
              illustrationAsset: AssetPaths.animalLion,
              animalSound: 'lion',
            ),
            QuizOption(
              label: 'Rooster',
              illustrationAsset: AssetPaths.animalRooster,
              animalSound: 'rooster',
            ),
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
            QuizOption(
              label: 'Monkey',
              illustrationAsset: AssetPaths.animalMonkey,
              animalSound: 'monkey',
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // LEVEL 4: EASY - Forest Explorers
    // ==========================================
    QuizLevel(
      levelNumber: 4,
      title: 'Forest Explorers',
      subtitle: 'Wise night birds and playful forest companions',
      difficulty: 'Easy',
      themeColor: Color(0xFF10B981),
      icon: Icons.forest_rounded,
      xpReward: 45,
      questions: [
        QuizQuestion(
          id: 'l4_q1',
          questionText: 'Which wise night bird calls out with...?',
          illustrationAsset: AssetPaths.birdOwl,
          humanPrompt: 'Which wise night bird calls out with...',
          animalSound: 'owl',
          soundDescription: 'Hoot Hoot 🦉',
          difficulty: 'Easy',
          funFact: 'Owls can turn their heads almost all the way around to look behind them!',
          correctOptionIndex: 0,
          options: [
            QuizOption(
              label: 'Owl',
              illustrationAsset: AssetPaths.birdOwl,
              animalSound: 'owl',
            ),
            QuizOption(
              label: 'Rooster',
              illustrationAsset: AssetPaths.animalRooster,
              animalSound: 'rooster',
            ),
            QuizOption(
              label: 'Bird',
              illustrationAsset: AssetPaths.birdSparrow,
              animalSound: 'bird',
            ),
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l4_q2',
          questionText: 'Listen to this sound! Which playful pet is barking?',
          illustrationAsset: AssetPaths.animalDog,
          humanPrompt: 'Listen to this sound! Which playful pet is barking?',
          animalSound: 'dog',
          soundDescription: 'Woof Woof 🐶',
          difficulty: 'Easy',
          funFact: 'Puppies have a super sense of smell 10,000 times stronger than humans!',
          correctOptionIndex: 1,
          options: [
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
            QuizOption(
              label: 'Sheep',
              illustrationAsset: AssetPaths.animalSheep,
              animalSound: 'sheep',
            ),
            QuizOption(
              label: 'Horse',
              illustrationAsset: AssetPaths.animalHorse,
              animalSound: 'horse',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l4_q3',
          questionText: 'Which creature with a big golden mane says...?',
          illustrationAsset: AssetPaths.animalLion,
          humanPrompt: 'Which creature with a big golden mane says...',
          animalSound: 'lion',
          soundDescription: 'Roar 🦁',
          difficulty: 'Easy',
          funFact: 'Lions love napping in warm sunlight for up to 20 hours a day!',
          correctOptionIndex: 2,
          options: [
            QuizOption(
              label: 'Elephant',
              illustrationAsset: AssetPaths.animalElephant,
              animalSound: 'elephant',
            ),
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
            QuizOption(
              label: 'Lion',
              illustrationAsset: AssetPaths.animalLion,
              animalSound: 'lion',
            ),
            QuizOption(
              label: 'Monkey',
              illustrationAsset: AssetPaths.animalMonkey,
              animalSound: 'monkey',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l4_q4',
          questionText: 'Which black and white spotted animal says...?',
          illustrationAsset: AssetPaths.animalCow,
          humanPrompt: 'Which black and white spotted animal says...',
          animalSound: 'cow',
          soundDescription: 'Moo 🐄',
          difficulty: 'Easy',
          funFact: 'Cows have best friends and get happy when they graze side-by-side!',
          correctOptionIndex: 3,
          options: [
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // LEVEL 5: MEDIUM - Curious Critters
    // ==========================================
    QuizLevel(
      levelNumber: 5,
      title: 'Curious Critters',
      subtitle: 'Water pond divers and playful tree climbers',
      difficulty: 'Medium',
      themeColor: AppColors.primaryPurple,
      icon: Icons.search_rounded,
      xpReward: 50,
      questions: [
        QuizQuestion(
          id: 'l5_q1',
          questionText: 'Which yellow bird splashes in the pond and says...?',
          illustrationAsset: AssetPaths.animalDuck,
          humanPrompt: 'Which yellow bird splashes in the pond and says...',
          animalSound: 'duck',
          soundDescription: 'Quack Quack 🦆',
          difficulty: 'Medium',
          funFact: 'Duck feathers are waterproof because of natural oils that keep them dry!',
          correctOptionIndex: 0,
          options: [
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
            QuizOption(
              label: 'Rooster',
              illustrationAsset: AssetPaths.animalRooster,
              animalSound: 'rooster',
            ),
            QuizOption(
              label: 'Owl',
              illustrationAsset: AssetPaths.birdOwl,
              animalSound: 'owl',
            ),
            QuizOption(
              label: 'Bird',
              illustrationAsset: AssetPaths.birdSparrow,
              animalSound: 'bird',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l5_q2',
          questionText: 'Which agile pet purrs softly and says...?',
          illustrationAsset: AssetPaths.animalCat,
          humanPrompt: 'Which agile pet purrs softly and says...',
          animalSound: 'cat',
          soundDescription: 'Meow 🐱',
          difficulty: 'Medium',
          funFact: 'Cats can jump up to 6 times their height in one graceful leap!',
          correctOptionIndex: 1,
          options: [
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Frog',
              illustrationAsset: AssetPaths.animalFrog,
              animalSound: 'frog',
            ),
            QuizOption(
              label: 'Monkey',
              illustrationAsset: AssetPaths.animalMonkey,
              animalSound: 'monkey',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l5_q3',
          questionText: 'Which giant friend with fan-like ears trumpets...?',
          illustrationAsset: AssetPaths.animalElephant,
          humanPrompt: 'Which giant friend with fan-like ears trumpets...',
          animalSound: 'elephant',
          soundDescription: 'Trumpet 🐘',
          difficulty: 'Medium',
          funFact: 'An elephant’s trunk has over 40,000 muscles!',
          correctOptionIndex: 2,
          options: [
            QuizOption(
              label: 'Lion',
              illustrationAsset: AssetPaths.animalLion,
              animalSound: 'lion',
            ),
            QuizOption(
              label: 'Horse',
              illustrationAsset: AssetPaths.animalHorse,
              animalSound: 'horse',
            ),
            QuizOption(
              label: 'Elephant',
              illustrationAsset: AssetPaths.animalElephant,
              animalSound: 'elephant',
            ),
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l5_q4',
          questionText: 'Who sits on floating lily pads and croaks with...?',
          illustrationAsset: AssetPaths.animalFrog,
          humanPrompt: 'Who sits on floating lily pads and croaks with...',
          animalSound: 'frog',
          soundDescription: 'Ribbit Ribbit 🐸',
          difficulty: 'Medium',
          funFact: 'Baby frogs start their lives as swimming tadpoles with tails!',
          correctOptionIndex: 3,
          options: [
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
            QuizOption(
              label: 'Bird',
              illustrationAsset: AssetPaths.birdSparrow,
              animalSound: 'bird',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Frog',
              illustrationAsset: AssetPaths.animalFrog,
              animalSound: 'frog',
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // LEVEL 6: MEDIUM - Sunny Pastures
    // ==========================================
    QuizLevel(
      levelNumber: 6,
      title: 'Sunny Pastures',
      subtitle: 'Early risers and energetic farm buddies',
      difficulty: 'Medium',
      themeColor: Color(0xFFEC4899),
      icon: Icons.wb_sunny_rounded,
      xpReward: 55,
      questions: [
        QuizQuestion(
          id: 'l6_q1',
          questionText: 'Who crows cheerfully on top of the fence at dawn?',
          illustrationAsset: AssetPaths.animalRooster,
          humanPrompt: 'Who crows cheerfully on top of the fence at dawn?',
          animalSound: 'rooster',
          soundDescription: 'Cock-a-doodle-doo 🐓',
          difficulty: 'Medium',
          funFact: 'Roosters have bright red combs on top of their heads!',
          correctOptionIndex: 0,
          options: [
            QuizOption(
              label: 'Rooster',
              illustrationAsset: AssetPaths.animalRooster,
              animalSound: 'rooster',
            ),
            QuizOption(
              label: 'Owl',
              illustrationAsset: AssetPaths.birdOwl,
              animalSound: 'owl',
            ),
            QuizOption(
              label: 'Bird',
              illustrationAsset: AssetPaths.birdSparrow,
              animalSound: 'bird',
            ),
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l6_q2',
          questionText: 'Who gives warm fluffy wool for knitted sweaters?',
          illustrationAsset: AssetPaths.animalSheep,
          humanPrompt: 'Who gives warm fluffy wool for knitted sweaters?',
          animalSound: 'sheep',
          soundDescription: 'Baa Baa 🐑',
          difficulty: 'Medium',
          funFact: 'A mama sheep is called an ewe, and her cute baby is called a lamb!',
          correctOptionIndex: 1,
          options: [
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
            QuizOption(
              label: 'Sheep',
              illustrationAsset: AssetPaths.animalSheep,
              animalSound: 'sheep',
            ),
            QuizOption(
              label: 'Horse',
              illustrationAsset: AssetPaths.animalHorse,
              animalSound: 'horse',
            ),
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l6_q3',
          questionText: 'Who wears shiny iron shoes and gallops fast across hills?',
          illustrationAsset: AssetPaths.animalHorse,
          humanPrompt: 'Who wears shiny iron shoes and gallops fast across hills?',
          animalSound: 'horse',
          soundDescription: 'Neigh Neigh 🐴',
          difficulty: 'Medium',
          funFact: 'Horses can run within a few hours after being born!',
          correctOptionIndex: 2,
          options: [
            QuizOption(
              label: 'Elephant',
              illustrationAsset: AssetPaths.animalElephant,
              animalSound: 'elephant',
            ),
            QuizOption(
              label: 'Lion',
              illustrationAsset: AssetPaths.animalLion,
              animalSound: 'lion',
            ),
            QuizOption(
              label: 'Horse',
              illustrationAsset: AssetPaths.animalHorse,
              animalSound: 'horse',
            ),
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l6_q4',
          questionText: 'Who loves sweet yellow bananas and swings with glee?',
          illustrationAsset: AssetPaths.animalMonkey,
          humanPrompt: 'Who loves sweet yellow bananas and swings with glee?',
          animalSound: 'monkey',
          soundDescription: 'Ooh-Ooh Aah-Aah 🐵',
          difficulty: 'Medium',
          funFact: 'Monkeys peel bananas from the bottom up, which is easier!',
          correctOptionIndex: 3,
          options: [
            QuizOption(
              label: 'Frog',
              illustrationAsset: AssetPaths.animalFrog,
              animalSound: 'frog',
            ),
            QuizOption(
              label: 'Lion',
              illustrationAsset: AssetPaths.animalLion,
              animalSound: 'lion',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Monkey',
              illustrationAsset: AssetPaths.animalMonkey,
              animalSound: 'monkey',
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // LEVEL 7: HARD - Detective Riddles
    // ==========================================
    QuizLevel(
      levelNumber: 7,
      title: 'Detective Riddles',
      subtitle: 'Mystery clues, secret calls, and sound riddles',
      difficulty: 'Hard',
      themeColor: Color(0xFF6366F1),
      icon: Icons.psychology_rounded,
      xpReward: 60,
      questions: [
        QuizQuestion(
          id: 'l7_q1',
          questionText: 'Riddle: I hunt by night and hoot softly from the trees. Who am I?',
          illustrationAsset: AssetPaths.birdOwl,
          humanPrompt: 'Riddle: I hunt by night and hoot softly from the trees. Who am I?',
          animalSound: 'owl',
          soundDescription: 'Hoot Hoot 🦉',
          difficulty: 'Hard',
          funFact: 'Owls have special feathers that make their flight completely silent!',
          correctOptionIndex: 0,
          options: [
            QuizOption(
              label: 'Owl',
              illustrationAsset: AssetPaths.birdOwl,
              animalSound: 'owl',
            ),
            QuizOption(
              label: 'Bird',
              illustrationAsset: AssetPaths.birdSparrow,
              animalSound: 'bird',
            ),
            QuizOption(
              label: 'Rooster',
              illustrationAsset: AssetPaths.animalRooster,
              animalSound: 'rooster',
            ),
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l7_q2',
          questionText: 'Riddle: I build twig nests, chirp at dawn, and fly high. Who am I?',
          illustrationAsset: AssetPaths.birdSparrow,
          humanPrompt: 'Riddle: I build twig nests, chirp at dawn, and fly high. Who am I?',
          animalSound: 'bird',
          soundDescription: 'Chirp Chirp 🐦',
          difficulty: 'Hard',
          funFact: 'Birds have hollow bones which make them light enough to soar in the sky!',
          correctOptionIndex: 1,
          options: [
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
            QuizOption(
              label: 'Bird',
              illustrationAsset: AssetPaths.birdSparrow,
              animalSound: 'bird',
            ),
            QuizOption(
              label: 'Frog',
              illustrationAsset: AssetPaths.animalFrog,
              animalSound: 'frog',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l7_q3',
          questionText: 'Riddle: I guard your front door and bark with loyalty. Who am I?',
          illustrationAsset: AssetPaths.animalDog,
          humanPrompt: 'Riddle: I guard your front door and bark with loyalty. Who am I?',
          animalSound: 'dog',
          soundDescription: 'Woof Woof 🐕',
          difficulty: 'Hard',
          funFact: 'A dog’s hearing is four times more sensitive than human ears!',
          correctOptionIndex: 2,
          options: [
            QuizOption(
              label: 'Sheep',
              illustrationAsset: AssetPaths.animalSheep,
              animalSound: 'sheep',
            ),
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l7_q4',
          questionText: 'Riddle: I rule the plains with a golden crown of hair and a mighty...?',
          illustrationAsset: AssetPaths.animalLion,
          humanPrompt: 'Riddle: I rule the plains with a golden crown of hair and a mighty...',
          animalSound: 'lion',
          soundDescription: 'Roar 🦁',
          difficulty: 'Hard',
          funFact: 'Lions live together in close-knit family groups called prides!',
          correctOptionIndex: 3,
          options: [
            QuizOption(
              label: 'Elephant',
              illustrationAsset: AssetPaths.animalElephant,
              animalSound: 'elephant',
            ),
            QuizOption(
              label: 'Monkey',
              illustrationAsset: AssetPaths.animalMonkey,
              animalSound: 'monkey',
            ),
            QuizOption(
              label: 'Horse',
              illustrationAsset: AssetPaths.animalHorse,
              animalSound: 'horse',
            ),
            QuizOption(
              label: 'Lion',
              illustrationAsset: AssetPaths.animalLion,
              animalSound: 'lion',
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // LEVEL 8: HARD - Animal Secrets
    // ==========================================
    QuizLevel(
      levelNumber: 8,
      title: 'Animal Secrets',
      subtitle: 'Nutritious treats, babies, and amazing traits',
      difficulty: 'Hard',
      themeColor: Color(0xFF0EA5E9),
      icon: Icons.auto_awesome_rounded,
      xpReward: 65,
      questions: [
        QuizQuestion(
          id: 'l8_q1',
          questionText: 'Listen to this sound! What fresh drink does this animal provide?',
          illustrationAsset: AssetPaths.animalCow,
          humanPrompt: 'Listen to this sound! What fresh drink does this animal provide?',
          animalSound: 'cow',
          soundDescription: 'Moo 🐄',
          difficulty: 'Hard',
          funFact: 'Fresh milk gives us calcium for strong bones and shiny teeth!',
          correctOptionIndex: 0,
          options: [
            QuizOption(
              label: 'Fresh Milk',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
            QuizOption(
              label: 'Orange Juice',
              illustrationAsset: AssetPaths.fruitOrange,
            ),
            QuizOption(
              label: 'Sweet Honey',
              illustrationAsset: AssetPaths.appleIllustration,
            ),
            QuizOption(
              label: 'Warm Tea',
              illustrationAsset: AssetPaths.shapeHeart,
            ),
          ],
        ),
        QuizQuestion(
          id: 'l8_q2',
          questionText: 'Listen to this farm sound! What is this animal’s cute baby called?',
          illustrationAsset: AssetPaths.animalSheep,
          humanPrompt: 'Listen to this farm sound! What is this animal’s cute baby called?',
          animalSound: 'sheep',
          soundDescription: 'Baa Baa 🐑',
          difficulty: 'Hard',
          funFact: 'A newborn lamb can recognize its mother’s unique bleat right away!',
          correctOptionIndex: 1,
          options: [
            QuizOption(
              label: 'Puppy',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
            QuizOption(
              label: 'Lamb',
              illustrationAsset: AssetPaths.animalSheep,
              animalSound: 'sheep',
            ),
            QuizOption(
              label: 'Kitten',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Duckling',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l8_q3',
          questionText: 'Which majestic creature uses its long trunk to splash cool water?',
          illustrationAsset: AssetPaths.animalElephant,
          humanPrompt: 'Which majestic creature uses its long trunk to splash cool water?',
          animalSound: 'elephant',
          soundDescription: 'Trumpet 🐘',
          difficulty: 'Hard',
          funFact: 'Elephants love bathing and spraying dust on their backs for sun protection!',
          correctOptionIndex: 2,
          options: [
            QuizOption(
              label: 'Lion',
              illustrationAsset: AssetPaths.animalLion,
              animalSound: 'lion',
            ),
            QuizOption(
              label: 'Horse',
              illustrationAsset: AssetPaths.animalHorse,
              animalSound: 'horse',
            ),
            QuizOption(
              label: 'Elephant',
              illustrationAsset: AssetPaths.animalElephant,
              animalSound: 'elephant',
            ),
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l8_q4',
          questionText: 'Who walks on soft silent paws and hunts mice in the garden?',
          illustrationAsset: AssetPaths.animalCat,
          humanPrompt: 'Who walks on soft silent paws and hunts mice in the garden?',
          animalSound: 'cat',
          soundDescription: 'Meow 🐱',
          difficulty: 'Hard',
          funFact: 'Cats have whiskers that act like built-in radar to judge narrow spaces!',
          correctOptionIndex: 3,
          options: [
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
            QuizOption(
              label: 'Frog',
              illustrationAsset: AssetPaths.animalFrog,
              animalSound: 'frog',
            ),
            QuizOption(
              label: 'Monkey',
              illustrationAsset: AssetPaths.animalMonkey,
              animalSound: 'monkey',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // LEVEL 9: VERY HARD - Nature Champions
    // ==========================================
    QuizLevel(
      levelNumber: 9,
      title: 'Nature Champions',
      subtitle: 'Habitats, sunrise alarms, and animal movements',
      difficulty: 'Very Hard',
      themeColor: Color(0xFFF97316),
      icon: Icons.emoji_events_rounded,
      xpReward: 70,
      questions: [
        QuizQuestion(
          id: 'l9_q1',
          questionText: 'Mystery Habitat: Listen to this croak! Where does this creature thrive?',
          illustrationAsset: AssetPaths.animalFrog,
          humanPrompt: 'Mystery Habitat: Listen to this croak! Where does this creature thrive?',
          animalSound: 'frog',
          soundDescription: 'Ribbit Ribbit 🐸',
          difficulty: 'Very Hard',
          funFact: 'Frogs absorb water and breathe directly through their moist skin!',
          correctOptionIndex: 0,
          options: [
            QuizOption(
              label: 'Lily Ponds & Lakes',
              illustrationAsset: AssetPaths.animalFrog,
              animalSound: 'frog',
            ),
            QuizOption(
              label: 'Dry Sandy Desert',
              illustrationAsset: AssetPaths.sciSun,
            ),
            QuizOption(
              label: 'Snowy Mountain',
              illustrationAsset: AssetPaths.shapeDiamond,
            ),
            QuizOption(
              label: 'Deep Dark Cave',
              illustrationAsset: AssetPaths.shapeCircle,
            ),
          ],
        ),
        QuizQuestion(
          id: 'l9_q2',
          questionText: 'Mystery Clock: When this farm bird calls out, what time is it?',
          illustrationAsset: AssetPaths.animalRooster,
          humanPrompt: 'Mystery Clock: When this farm bird calls out, what time is it?',
          animalSound: 'rooster',
          soundDescription: 'Cock-a-doodle-doo 🐓',
          difficulty: 'Very Hard',
          funFact: 'Roosters have an internal biological clock that anticipates sunrise!',
          correctOptionIndex: 1,
          options: [
            QuizOption(
              label: 'Midnight Stars',
              illustrationAsset: AssetPaths.shapeStar,
            ),
            QuizOption(
              label: 'Early Sunrise',
              illustrationAsset: AssetPaths.animalRooster,
              animalSound: 'rooster',
            ),
            QuizOption(
              label: 'Lunch Time',
              illustrationAsset: AssetPaths.appleIllustration,
            ),
            QuizOption(
              label: 'Bedtime',
              illustrationAsset: AssetPaths.shapeCrescent,
            ),
          ],
        ),
        QuizQuestion(
          id: 'l9_q3',
          questionText: 'Mystery Motion: Listen to this neigh! How does this animal run fast?',
          illustrationAsset: AssetPaths.animalHorse,
          humanPrompt: 'Mystery Motion: Listen to this neigh! How does this animal run fast?',
          animalSound: 'horse',
          soundDescription: 'Neigh Neigh 🐴',
          difficulty: 'Very Hard',
          funFact: 'A horse gallops with a four-beat rhythm and reaches speeds over 40 mph!',
          correctOptionIndex: 2,
          options: [
            QuizOption(
              label: 'Slithering',
              illustrationAsset: AssetPaths.shapeTriangle,
            ),
            QuizOption(
              label: 'Flying High',
              illustrationAsset: AssetPaths.birdSparrow,
              animalSound: 'bird',
            ),
            QuizOption(
              label: 'Gallop & Trot',
              illustrationAsset: AssetPaths.animalHorse,
              animalSound: 'horse',
            ),
            QuizOption(
              label: 'Crawling Slow',
              illustrationAsset: AssetPaths.animalFrog,
              animalSound: 'frog',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l9_q4',
          questionText: 'Mystery Diet: Which sweet tropical fruit does this chattering friend adore?',
          illustrationAsset: AssetPaths.animalMonkey,
          humanPrompt: 'Mystery Diet: Which sweet tropical fruit does this chattering friend adore?',
          animalSound: 'monkey',
          soundDescription: 'Ooh-Ooh Aah-Aah 🐵',
          difficulty: 'Very Hard',
          funFact: 'Bananas are packed with potassium to give playful monkeys energy to jump!',
          correctOptionIndex: 3,
          options: [
            QuizOption(
              label: 'Watermelon',
              illustrationAsset: AssetPaths.fruitWatermelon,
            ),
            QuizOption(
              label: 'Strawberry',
              illustrationAsset: AssetPaths.fruitStrawberry,
            ),
            QuizOption(
              label: 'Carrot',
              illustrationAsset: AssetPaths.fruitCarrot,
            ),
            QuizOption(
              label: 'Sweet Banana',
              illustrationAsset: AssetPaths.fruitBanana,
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // LEVEL 10: VERY HARD - Grand Sound Master
    // ==========================================
    QuizLevel(
      levelNumber: 10,
      title: 'Grand Sound Master',
      subtitle: 'The ultimate animal sound championship',
      difficulty: 'Very Hard',
      themeColor: Color(0xFFEAB308),
      icon: Icons.military_tech_rounded,
      xpReward: 100,
      questions: [
        QuizQuestion(
          id: 'l10_q1',
          questionText: 'Master Riddle: "I sleep by day, hunt mice by night, and turn my head 270 degrees... Who am I?"',
          illustrationAsset: AssetPaths.birdOwl,
          humanPrompt: 'Master Riddle: I sleep by day, hunt mice by night, and turn my head 270 degrees... Who am I?',
          animalSound: 'owl',
          soundDescription: 'Hoot Hoot 🦉',
          difficulty: 'Very Hard',
          funFact: 'Owls do not have eyeballs; they have elongated eye tubes held in place by bones!',
          correctOptionIndex: 0,
          options: [
            QuizOption(
              label: 'Owl',
              illustrationAsset: AssetPaths.birdOwl,
              animalSound: 'owl',
            ),
            QuizOption(
              label: 'Eagle',
              illustrationAsset: AssetPaths.birdEagle,
            ),
            QuizOption(
              label: 'Parrot',
              illustrationAsset: AssetPaths.birdParrot,
            ),
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
          ],
        ),
        QuizQuestion(
          id: 'l10_q2',
          questionText: 'Master Riddle: "I am Earth\'s largest land giant, with a trumpet call and cooling ears... Who am I?"',
          illustrationAsset: AssetPaths.animalElephant,
          humanPrompt: 'Master Riddle: I am Earth\'s largest land giant, with a trumpet call and cooling ears... Who am I?',
          animalSound: 'elephant',
          soundDescription: 'Trumpet 🐘',
          difficulty: 'Very Hard',
          funFact: 'Elephants can communicate across long distances using low-frequency rumbles!',
          correctOptionIndex: 1,
          options: [
            QuizOption(
              label: 'Giraffe',
              illustrationAsset: AssetPaths.animalGiraffe,
            ),
            QuizOption(
              label: 'Elephant',
              illustrationAsset: AssetPaths.animalElephant,
              animalSound: 'elephant',
            ),
            QuizOption(
              label: 'Tiger',
              illustrationAsset: AssetPaths.animalTiger,
            ),
            QuizOption(
              label: 'Bear',
              illustrationAsset: AssetPaths.animalBear,
            ),
          ],
        ),
        QuizQuestion(
          id: 'l10_q3',
          questionText: 'Master Riddle: "Golden mane, paws of power, undisputed ruler of the great plains... Who am I?"',
          illustrationAsset: AssetPaths.animalLion,
          humanPrompt: 'Master Riddle: Golden mane, paws of power, undisputed ruler of the great plains... Who am I?',
          animalSound: 'lion',
          soundDescription: 'Roar 🦁',
          difficulty: 'Very Hard',
          funFact: 'A lioness does most of the hunting for the pride while the lion protects the territory!',
          correctOptionIndex: 2,
          options: [
            QuizOption(
              label: 'Horse',
              illustrationAsset: AssetPaths.animalHorse,
              animalSound: 'horse',
            ),
            QuizOption(
              label: 'Dog',
              illustrationAsset: AssetPaths.animalDog,
              animalSound: 'dog',
            ),
            QuizOption(
              label: 'Lion',
              illustrationAsset: AssetPaths.animalLion,
              animalSound: 'lion',
            ),
            QuizOption(
              label: 'Panda',
              illustrationAsset: AssetPaths.animalPanda,
            ),
          ],
        ),
        QuizQuestion(
          id: 'l10_q4',
          questionText: 'Master Riddle: "I chew sweet cud, graze peacefully on hills, and produce rich creamy milk... Who am I?"',
          illustrationAsset: AssetPaths.animalCow,
          humanPrompt: 'Master Riddle: I chew sweet cud, graze peacefully on hills, and produce rich creamy milk... Who am I?',
          animalSound: 'cow',
          soundDescription: 'Moo 🐄',
          difficulty: 'Very Hard',
          funFact: 'Cows spend nearly 8 hours a day chewing their cud to stay healthy and strong!',
          correctOptionIndex: 3,
          options: [
            QuizOption(
              label: 'Sheep',
              illustrationAsset: AssetPaths.animalSheep,
              animalSound: 'sheep',
            ),
            QuizOption(
              label: 'Duck',
              illustrationAsset: AssetPaths.animalDuck,
              animalSound: 'duck',
            ),
            QuizOption(
              label: 'Cat',
              illustrationAsset: AssetPaths.animalCat,
              animalSound: 'cat',
            ),
            QuizOption(
              label: 'Cow',
              illustrationAsset: AssetPaths.animalCow,
              animalSound: 'cow',
            ),
          ],
        ),
      ],
    ),
  ];
}
