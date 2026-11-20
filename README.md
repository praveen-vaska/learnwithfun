# LearnWithFun – Kids Smart Learning App (Production Flutter Frontend & Local Backend)

**LearnWithFun** is a cheerful, high-quality, and interactive educational Flutter mobile app designed for children aged 3–12. It provides a complete, production-ready frontend with an offline-first persistent local backend using `SharedPreferences`, multi-category learning modules (ABC, Numbers, Animals, Shapes, Fruits, Birds, Vehicles, Body Parts, Science Fun), real animal sounds, natural speech synthesis, and 3 playable mini-games.

---

## 🎨 Visual Design System & Palette

Directly adapted from the official UI design specification:
- **Primary Purple:** `#7952F5`
- **Deep Purple:** `#6842E8`
- **Lavender:** `#A68BFF`
- **Yellow Accent:** `#FFE16A` / `#F59E0B`
- **Sky Blue:** `#83D9FA`
- **Lime Green:** `#C4ED65` / `#10B981`
- **Pink:** `#FFB7CB` / `#F43F5E`
- **Cream / Surface:** `#FFF4E9` / `#F7F5FC`
- **Main Text:** `#292536`
- **Border Radius:** 20–26px pill cards and bouncy spring feedback.
- **Typography:** Nunito (Body) & Baloo 2 (Headings & Big Letter displays via `google_fonts`).

---

## 🔊 Audio Engine & Animal Sounds
The app features a zero-network, hybrid audio engine located at `lib/core/services/audio_service.dart`:
1. **Real Animal Sounds:** In-memory 16-bit mono PCM WAV wave synthesis paired with expressive child-friendly vocalizations for **Cow, Cat, Lion, Duck, Dog, Sheep, Elephant, Monkey, Bird/Parrot**.
2. **Text-to-Speech (TTS):** Natural speech synthesis with `FlutterTts` configured at rate `0.42` and pitch `1.2` for warm, clear kid narration of lessons, quiz questions, and story pages.
3. **Audio Micro-Interactions:** Tactile button tap pop (`playTapSound`), card flip whoosh (`playCardFlipSound`), ascending triad chime on correct answer (`playSuccessChime`), victory celebration fanfare (`playCelebrationFanfare`), and gentle feedback for retries (`playIncorrectSound`).

---

## 💾 Local Persistent Backend (`LocalStorageService`)
Located at `lib/data/services/local_storage_service.dart`:
- Persists child profile (name, age, level, XP, streak, avatar, audio preferences) across app restarts using `SharedPreferences`.
- Persists completed lesson IDs and dynamically calculates category progress and parent statistics.
- Persists daily challenge completion and claim states.
- Persists unlocked achievement badges.
- Tracks daily screen time and parental lock controls.

---

## 📱 Implemented Screens & Modules

### A. Entry & Onboarding Flow
1. **Splash Screen:** Purple gradient, animated floating stars, mascots (reading hero & panda), and "Start Learning" action.
2. **Onboarding Carousel (3 Slides):**
   - *Slide 1:* "Fun Learning for Curious Kids!" (Boy zooming on rocket)
   - *Slide 2:* "Interactive Learning & Quizzes" (Girl with idea bulb)
   - *Slide 3:* "Play, Learn & Earn Rewards!" (Golden trophy & stars)
   - Skip option, page indicators, and Next/Get Started controls.
3. **Age Selection:** Interactive cards for 3–5 Years (Preschool Fun), 6–8 Years (Primary Learning), 9–12 Years (Advanced Learning).
4. **Language Selection:** English (default UK flag badge), Telugu, and Hindi frontend selection.
5. **Create Child Profile:** Name input ("Arab"), age dropdown, and avatar selector.
6. **Choose Avatar:** 6 distinct cartoon companions (Happy Boy, Sunny Girl, Cool Explorer, Little Genius, Cute Panda, Brave Lion).
7. **Profile Created:** Celebration with confetti burst and crown badge before entering home.

### B. Main App (5 Bottom Navigation Tabs)
8. **Home Dashboard:**
   - Child avatar greeting ("Hi, Arab! Let's learn something new!")
   - Notification bell with unread indicator dot
   - **Daily Challenge Banner:** Golden trophy, challenge text, +20 XP, and "Let's Go" action
   - **Categories 2x2 Grid:** ABC Learning, 123 Numbers, Animals World, Shapes & Colors
   - **Continue Learning Card:** Progress bar, Letter A lesson card, and play button
   - **Stats Ribbon:** XP, Level, and Day Streak pills
   - Shortcuts to Mini Games & Bedtime Stories
9. **All Categories Screen ("Learn" tab):**
   - 9 learning categories: ABC Learning, 123 Numbers, Animals World, Shapes & Colors, Fruits & Veggies, Birds Learning, Vehicles Learning, Body Parts, Science Fun.
10. **Topic Grid Screen (`AlphabetGridScreen`):**
    - Context-aware layouts: 4-column A–Z letter grid, 3-column playful numbers grid, and 2-column illustrated cards with instant sound buttons for Animals, Shapes, Fruits, Vehicles, and Birds!
11. **Lesson Screen:**
    - Top progress counter (e.g. `1 / 26`)
    - Giant concept display (Letters, Numbers, Animals, Shapes)
    - High-detail vector graphics and interactive illustrations
    - Tap on the illustration or speaker button to trigger real audio / animal sound!
    - Previous and Next buttons with automatic XP award on completion.
12. **Quiz Intro Screen:**
    - Topic overview, question count, reward points, and "Start Quiz" button.
13. **Quiz Question Screen (Matching reference screen):**
    - Top bar: back button, progress indicator (`1 / 5`), audio prompt button
    - Scenic meadow landscape illustration
    - Question text: *"Which animal says 'Moo'?"* with spoken audio prompt
    - 4 illustrated option cards (Cow, Cat, Lion, Duck) with tap sound feedback
    - Correct answer: Green highlight + confetti celebration + star chime.
    - Incorrect answer: Soft bounce + encouraging feedback.
14. **Quiz Result Screen:**
    - Golden trophy with sparkles, score counter (`4 / 5`), glowing `+40 XP` badge, 3 animated golden stars, and "Continue" actions.
15. **Playable Mini-Games Suite (`MiniGamesScreen`):**
    - **Game 1: Match the Pairs (Memory Match):** 3D flipping cards, sound whoosh, match chime, timer, and victory fanfare!
    - **Game 2: Animal Sound Guess:** Child listens to real animal vocalizations, replays sound, and guesses the matching animal!
    - **Game 3: Count & Learn:** Interactive bouncing objects with tap-to-count voice feedback and 4 number selection buttons!
16. **Daily Challenge Screen:**
    - List of tasks with XP values and play shortcuts
    - Big Gift Treasure box to claim +50 XP bonus when all tasks are complete.
17. **Rewards Screen ("Rewards" tab):**
    - Level progress bar (e.g. `450 / 600 XP`)
    - Total XP, Stars, and Streak stats
    - 8 achievements with locked/unlocked visual badges and tap-to-inspect dialogs.
18. **Stories & Rhymes Screen:**
    - Tab toggle: `[Stories]` and `[Rhymes]`
    - Story cards with thumbnails, duration, moral lesson, and audio buttons.
19. **Story Reader Screen:**
    - Scenic cover illustration, moral subtitle
    - Story text with page-by-page reading controls
    - Play button speaks the current page aloud via `FlutterTts` and updates playback slider.
20. **Profile Screen ("Profile" tab):**
    - Avatar, child name, age, level, and XP
    - Navigation to My Progress, Achievements, My Avatar, Parent Zone, and Settings.
21. **My Learning Progress Screen:**
    - 75% circular progress gauge and category breakdown progress bars.
22. **Parent Zone Gate:**
    - Arithmetic security gate (e.g. `7 + 8 = ?`) preventing accidental child access to parent controls.
23. **Parent Dashboard:**
    - Weekly statistics: Learning Time (2h 15m), Lessons (28), Quiz Accuracy (88%), Current Streak (5 Days)
    - Mon–Sun interactive bar chart, category performance bars, and time limits.
24. **Screen Time & Parental Controls:**
    - Daily limit slider (e.g. 60 Minutes) and break reminders.
25. **Settings Screen:**
    - Sound Effects toggle, Background Music toggle, Language selector, Theme preferences, About Us dialog, Privacy Policy dialog.
26. **Notifications Screen:**
    - Realistic notification cards (Streak on fire, New story unlocked, Daily challenge ready) with "Mark All Read".

---

## 🧪 Testing & Verification
All unit tests and smoke tests pass with 0 warnings:
```bash
flutter analyze
# No issues found!

flutter test
# All tests passed! (6 tests in unit_test.dart and widget_test.dart)
```
