# LearnWithFun – Manual QA Checklist

This checklist verifies all screens, animations, local state interactions, audio effects, and persistence for the client demo.

| # | Screen / Area | Action / Verification | Expected Result | Status |
|---|---|---|---|:---:|
| 1 | **Splash Screen** | Launch app | Logo scales in, stars float softly, character illustrations render smoothly, "Start Learning" triggers navigation | Passed |
| 2 | **Onboarding** | Swipe/Tap Next across 3 slides | Slide 1 (Rocket), Slide 2 (Learning), Slide 3 (Trophy) show animated illustrations; dots update; Skip opens Age Selection | Passed |
| 3 | **Age Selection** | Select 3–5, 6–8, or 9–12 Years | Tapped card receives purple glow and checkmark; Continue passes selection forward | Passed |
| 4 | **Language Selection** | Select English, Telugu, or Hindi | Chosen language highlights with checkmark; updates state; Continue advances to Profile | Passed |
| 5 | **Child Profile** | Enter Name ("Arab"), select Age (6), tap avatar | Avatar modal opens; changing avatar updates preview; tapping Continue advances with confirmation | Passed |
| 6 | **Choose Avatar** | Pick 1 of 6 cartoon avatars | Selected avatar gets purple badge and persists to profile and home greeting | Passed |
| 7 | **Profile Created** | Observe celebration screen | Confetti bursts, congratulations message displayed, "Go to Home" opens dashboard | Passed |
| 8 | **Home Dashboard** | Bottom navigation tabs | All 5 tabs (Home, Learn, Quiz, Rewards, Profile) switch smoothly without rebuilding entire stack | Passed |
| 9 | **Daily Challenge Banner** | Tap "Let's Go" on home banner | Opens Daily Challenge screen with task list and reward values | Passed |
| 10 | **Categories Grid** | Tap "Animals World" / "123 Numbers" / "ABC" | Opens category grid showing full card sets tailored to the category | Passed |
| 11 | **Topic / Lesson Screen** | Open Animal lesson (Cow/Lion) | Big illustration renders; tap illustration or audio button plays real synthesized animal sound (Moo/Roar); Next awards XP | Passed |
| 12 | **Quiz Intro** | Tap "Start Quiz" | Opens Question 1 with scenic meadow illustration, progress `1 / 5`, and audio prompt | Passed |
| 13 | **Quiz Question** | Select an answer option | Tapped card turns purple with tap sound; audio button speaks prompt aloud; correct answer triggers green border, confetti, and star chime | Passed |
| 14 | **Quiz Results** | Finish question 5 | Result screen displays score, earned XP (+40 XP), 3 golden stars, and adds XP to ChildProfile state | Passed |
| 15 | **Mini Game 1 (Memory Match)** | Flip cards | Cards flip with 3D animation and whoosh sound; matching pairs stay revealed with chime; victory fanfare pops on win | Passed |
| 16 | **Mini Game 2 (Animal Sound Guess)** | Listen and guess animal | Plays animal sound, child taps matching animal card; success chime on correct pick, fanfare on round completion | Passed |
| 17 | **Mini Game 3 (Count & Learn)** | Tap objects & select number | Child counts bouncing items with voice feedback; selects matching number; confetti celebration | Passed |
| 18 | **Daily Challenges** | Check off tasks & claim bonus | Completing tasks activates the 50 XP Gift Box; claiming adds +50 XP, plays confetti, and persists to storage | Passed |
| 19 | **Rewards Screen** | Inspect Level progress & Badges | Shows 450/600 XP progress bar, XP total, 5 Stars, 5 Day Streak; tapping badges opens detail dialog | Passed |
| 20 | **Stories & Rhymes** | Toggle Stories / Rhymes tabs | Stories list filters accordingly; tapping story opens Story Reader | Passed |
| 21 | **Story Reader** | Play audio & turn pages | Scenic illustration loads; play button narrate story aloud via TTS and updates slider; page turn reads new page | Passed |
| 22 | **Parent Zone Gate** | Tap Parent Zone in Profile | Arithmetic modal displays (e.g. `7 + 8 = ?`); incorrect answer shows error; correct answer unlocks Parent Dashboard | Passed |
| 23 | **Parent Dashboard** | Inspect weekly chart | Displays Arab (6 Years), 2h 15m learning time, 28 lessons, 88% accuracy, 5-day streak, and Mon–Sun bar chart | Passed |
| 24 | **Screen Time** | Toggle daily limits & reminders | Adjusting slider/dropdown and saving persists state changes to UserCubit and LocalStorageService | Passed |
| 25 | **Settings** | Sound / Music / Notifications toggles | Toggles update local state and sync with AppAudioService; About Us and Privacy Policy open cleanly | Passed |
| 26 | **Notifications** | Open notification bell on Home | Mock notification list renders with unread dots; "Read All" marks them read | Passed |
