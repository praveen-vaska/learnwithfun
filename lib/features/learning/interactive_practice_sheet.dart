import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../blocs/user_cubit.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../data/models/lesson.dart';
import 'tracing_guide.dart';

/// Interactive Practice Sheet for Kids (Duolingo Style)
/// Features:
/// 1. 2-Step Voice Practice with Automatic Speech Matching:
///    - Step 1: Say the Letter/Symbol (e.g., "Say: A!") -> Matches strictly ("A"), rejects ("B")
///    - Step 2: Say the Word Association (e.g., "Now say: A for Apple!")
///    - Automatically checks and advances immediately when speech matches!
/// 2. 2-Step Accurate Trace & Draw with Automatic Completion:
///    - Step 1: Trace the Letter/Symbol ('A')
///    - Step 2: Trace the Word ('APPLE') with wide gaps between letters
///    - Live checkpoint hit detection (dots light up glowing green as traced)
///    - Automatically checks & advances as soon as accurate tracing threshold (>=60%) is met!
class InteractivePracticeSheet extends StatefulWidget {
  final Lesson lesson;

  const InteractivePracticeSheet({super.key, required this.lesson});

  static Future<void> show(BuildContext context, {required Lesson lesson}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InteractivePracticeSheet(lesson: lesson),
    );
  }

  @override
  State<InteractivePracticeSheet> createState() =>
      _InteractivePracticeSheetState();
}

enum PracticeTab { voice, draw }

class _InteractivePracticeSheetState extends State<InteractivePracticeSheet>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ConfettiCelebrationState> _confettiKey =
      GlobalKey<ConfettiCelebrationState>();

  PracticeTab _currentTab = PracticeTab.voice;
  late AnimationController _pulseController;

  // --- Voice State ---
  int _voiceStage = 1; // 1 = Letter ('A'), 2 = Word ('A for Apple')
  stt.SpeechToText? _speech;
  bool _speechAvailable = false;
  bool _isListening = false;
  String _recognizedWords = '';
  bool _voiceStage1Success = false;
  bool _voiceStage2Success = false;
  String _voiceFeedback = '';

  // --- Drawing State ---
  int _drawStage = 1; // 1 = Trace Letter ('A'), 2 = Trace Word ('APPLE')
  final List<DrawingStroke> _strokesStage1 = [];
  final List<DrawingStroke> _strokesStage2 = [];
  Color _selectedColor = AppColors.primaryPurple;
  final double _strokeWidth = 12.0;
  bool _isEraser = false;
  bool _drawStage1Success = false;
  bool _drawStage2Success = false;

  final List<Color> _palette = const [
    AppColors.primaryPurple,
    AppColors.orange,
    AppColors.yellow,
    AppColors.green,
    AppColors.skyBlue,
    AppColors.pinkDark,
  ];

  // Phonetic & common transcription variants for English letters
  static const Map<String, List<String>> _letterPhonetics = {
    'A': ['a', 'ay', 'ei', 'eh', 'hey', 'letter a', 'apple'],
    'B': ['b', 'be', 'bee', 'letter b', 'ball', 'boy'],
    'C': ['c', 'see', 'sea', 'si', 'letter c', 'cat'],
    'D': ['d', 'dee', 'the', 'letter d', 'dog'],
    'E': ['e', 'ee', 'letter e', 'elephant', 'egg'],
    'F': ['f', 'ef', 'eff', 'letter f', 'fish'],
    'G': ['g', 'jee', 'gee', 'letter g', 'grapes'],
    'H': ['h', 'aitch', 'eitch', 'letter h', 'hat', 'horse'],
    'I': ['i', 'eye', 'ai', 'ay', 'letter i', 'ice cream', 'ice'],
    'J': ['j', 'jay', 'letter j', 'jug', 'juice'],
    'K': ['k', 'kay', 'letter k', 'kite'],
    'L': ['l', 'el', 'ell', 'letter l', 'lion'],
    'M': ['m', 'em', 'letter m', 'mango', 'monkey'],
    'N': ['n', 'en', 'letter n', 'nest', 'nose'],
    'O': ['o', 'oh', 'letter o', 'orange', 'owl'],
    'P': ['p', 'pee', 'letter p', 'parrot', 'pen'],
    'Q': ['q', 'cue', 'kew', 'letter q', 'queen'],
    'R': ['r', 'ar', 'are', 'letter r', 'rabbit', 'rose'],
    'S': ['s', 'es', 'ess', 'letter s', 'sun', 'star'],
    'T': ['t', 'tee', 'tea', 'letter t', 'tiger', 'tree'],
    'U': ['u', 'you', 'yu', 'letter u', 'umbrella'],
    'V': ['v', 'vee', 'letter v', 'van', 'violin'],
    'W': ['w', 'double u', 'double you', 'letter w', 'watch'],
    'X': ['x', 'ex', 'letter x', 'xylophone'],
    'Y': ['y', 'why', 'wai', 'letter y', 'yak', 'yellow'],
    'Z': ['z', 'zed', 'zee', 'letter z', 'zebra', 'zoo'],
  };

  static const Map<String, List<String>> _numberPhonetics = {
    '1': ['1', 'one', 'won', 'first', 'number 1', 'number one'],
    '2': ['2', 'two', 'to', 'too', 'second', 'number 2', 'number two'],
    '3': ['3', 'three', 'tree', 'third', 'number 3', 'number three'],
    '4': ['4', 'four', 'for', 'fore', 'number 4', 'number four'],
    '5': ['5', 'five', 'number 5', 'number five'],
    '6': ['6', 'six', 'number 6', 'number six'],
    '7': ['7', 'seven', 'number 7', 'number seven'],
    '8': ['8', 'eight', 'ate', 'number 8', 'number eight'],
    '9': ['9', 'nine', 'number 9', 'number nine'],
    '10': ['10', 'ten', 'number 10', 'number ten'],
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _initSpeechRecognizer();
    _playCurrentVoicePrompt();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stopListening();
    super.dispose();
  }

  // -------------------------------------------------------------
  // CONCEPT RESOLUTION (Letter, Word, Prompts)
  // -------------------------------------------------------------
  String get _stage1Symbol {
    final title = widget.lesson.title.trim();
    if (widget.lesson.categoryId == 'abc') {
      return title.split(' ').first.trim().toUpperCase();
    }
    if (title.startsWith('Number ')) {
      return title.replaceAll('Number ', '').trim();
    }
    if (title.startsWith('Letter ')) {
      return title.replaceAll('Letter ', '').trim();
    }
    if (widget.lesson.categoryId == 'animals') {
      return widget.lesson.title;
    }
    if (widget.lesson.categoryId == 'shapes') {
      return widget.lesson.conceptWord;
    }
    return title;
  }

  String get _stage2Word {
    if (widget.lesson.categoryId == 'abc') {
      return widget.lesson.conceptWord.isNotEmpty
          ? widget.lesson.conceptWord
          : 'Apple';
    } else if (widget.lesson.categoryId == '123') {
      return widget.lesson.conceptWord.isNotEmpty
          ? widget.lesson.conceptWord
          : 'One';
    } else if (widget.lesson.categoryId == 'animals') {
      final sound = widget.lesson.soundText;
      if (sound.contains('says ')) {
        return sound.split('says ').last.replaceAll('!', '').trim();
      }
      return 'Moo';
    } else if (widget.lesson.categoryId == 'shapes') {
      return 'Round';
    }
    return widget.lesson.conceptWord.isNotEmpty
        ? widget.lesson.conceptWord
        : 'Good';
  }

  String get _currentVoicePrompt {
    if (_voiceStage == 1) {
      if (widget.lesson.categoryId == 'abc') {
        return 'Say: $_stage1Symbol!';
      } else if (widget.lesson.categoryId == '123') {
        return 'Say: $_stage1Symbol!';
      } else if (widget.lesson.categoryId == 'animals') {
        return 'Say: $_stage1Symbol!';
      } else {
        return 'Say: $_stage1Symbol!';
      }
    } else {
      if (widget.lesson.categoryId == 'abc') {
        return 'Now say: $_stage1Symbol for $_stage2Word!';
      } else if (widget.lesson.categoryId == '123') {
        return 'Now say: $_stage1Symbol, $_stage2Word!';
      } else if (widget.lesson.categoryId == 'animals') {
        return 'Now say: $_stage1Symbol says $_stage2Word!';
      } else {
        return 'Now say: $_stage1Symbol, $_stage2Word!';
      }
    }
  }

  String get _currentDrawTarget {
    return _drawStage == 1 ? _stage1Symbol : _stage2Word;
  }

  List<DrawingStroke> get _activeStrokes {
    return _drawStage == 1 ? _strokesStage1 : _strokesStage2;
  }

  Future<void> _playCurrentVoicePrompt() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    AppAudioService.instance.speak(_currentVoicePrompt);
  }

  // -------------------------------------------------------------
  // SPEECH RECOGNITION (Voice Practice with Automatic Matching)
  // -------------------------------------------------------------
  Future<void> _initSpeechRecognizer() async {
    if (kIsWeb) return;
    try {
      _speech = stt.SpeechToText();
      final available = await _speech!.initialize(
        onError: (SpeechRecognitionError error) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
        onStatus: (String status) {
          if (mounted) {
            setState(() {
              _isListening = (status == 'listening');
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _speechAvailable = available;
        });
      }
    } catch (e) {
      debugPrint('Speech recognizer init error: $e');
    }
  }

  Future<void> _startListening() async {
    AppAudioService.instance.playTapSound();
    if (_speech == null || !_speechAvailable) {
      // Simulation / Toddler fallback
      setState(() {
        _isListening = true;
        _recognizedWords = 'Listening to your voice...';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _onVoiceSuccess(
          _voiceStage == 1 ? _stage1Symbol : '$_stage1Symbol for $_stage2Word',
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedWords = '';
      _voiceFeedback = '';
    });

    try {
      await _speech!.listen(
        onResult: (SpeechRecognitionResult result) {
          if (!mounted) return;
          final words = result.recognizedWords;
          setState(() {
            _recognizedWords = words;
          });
          _evaluateSpeech(words);
        },
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
      );
    } catch (e) {
      debugPrint('Speech listening error: $e');
    }
  }

  Future<void> _stopListening() async {
    if (_speech != null && _speech!.isListening) {
      await _speech!.stop();
    }
    if (mounted && _isListening) {
      setState(() {
        _isListening = false;
      });
    }
  }

  /// Evaluates speech strictly and triggers automatic success when matched
  void _evaluateSpeech(String rawWords) {
    final lower = rawWords.toLowerCase().trim();
    if (lower.isEmpty) return;

    if (_voiceStage == 1) {
      final symbol = _stage1Symbol.toUpperCase();
      bool isMatch = false;

      if (widget.lesson.categoryId == 'abc') {
        // Alphabet matching: check exact letter or phonetic variants
        final validVariants = _letterPhonetics[symbol] ?? [symbol.toLowerCase()];
        final tokens = lower.split(RegExp(r'[\s,\.\!\?]+'));
        isMatch = validVariants.any((v) => lower == v || tokens.contains(v));
      } else if (widget.lesson.categoryId == '123') {
        // Number matching
        final validVariants = _numberPhonetics[symbol] ?? [symbol.toLowerCase()];
        final tokens = lower.split(RegExp(r'[\s,\.\!\?]+'));
        isMatch = validVariants.any((v) => lower == v || tokens.contains(v));
      } else {
        // Words (animals, shapes, etc.)
        final target = _stage1Symbol.toLowerCase();
        isMatch = lower.contains(target);
      }

      if (isMatch) {
        if (!_voiceStage1Success) {
          _onVoiceSuccess(rawWords);
        }
      } else {
        // Give helpful live prompt if speech was heard but did not match
        setState(() {
          _voiceFeedback = 'Heard "$rawWords". Try saying "$_stage1Symbol"! 🎙️';
        });
      }
    } else {
      // Stage 2: Association (e.g. "Apple" or "A for Apple")
      final word = _stage2Word.toLowerCase();
      final letter = _stage1Symbol.toLowerCase();

      final isMatch = lower.contains(word) ||
          (lower.contains(letter) && (lower.contains('for') || lower.contains('is')));

      if (isMatch) {
        if (!_voiceStage2Success) {
          _onVoiceSuccess(rawWords);
        }
      } else {
        setState(() {
          _voiceFeedback =
              'Heard "$rawWords". Try saying "$_stage1Symbol for $_stage2Word"! 🎙️';
        });
      }
    }
  }

  void _onVoiceSuccess(String spokenText) {
    _stopListening();
    AppAudioService.instance.playSuccessChime();

    if (_voiceStage == 1) {
      setState(() {
        _voiceStage1Success = true;
        _voiceFeedback = 'Awesome! You said: "$spokenText" ⭐';
      });

      // Automatically advance to Stage 2 after 1.2 seconds
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          _voiceStage = 2;
          _recognizedWords = '';
          _voiceFeedback = '';
        });
        _playCurrentVoicePrompt();
      });
    } else {
      setState(() {
        _voiceStage2Success = true;
        _voiceFeedback = 'Superstar! You said: "$spokenText" 🌟🌟🌟';
      });

      _confettiKey.currentState?.play();
      context.read<UserCubit>().addXp(15);
      AppAudioService.instance.speak(
        'Outstanding job! You said both $_stage1Symbol and $_stage2Word! 15 stars for you!',
      );
    }
  }

  // -------------------------------------------------------------
  // TRACING & DRAWING (Canvas with Automatic Hit-Checking)
  // -------------------------------------------------------------
  void _onPanStart(DragStartDetails details, RenderBox box) {
    final localPosition = box.globalToLocal(details.globalPosition);
    setState(() {
      _activeStrokes.add(
        DrawingStroke(
          points: [localPosition],
          color: _isEraser ? Colors.white : _selectedColor,
          strokeWidth: _isEraser ? 24.0 : _strokeWidth,
          isEraser: _isEraser,
        ),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details, RenderBox box) {
    final localPosition = box.globalToLocal(details.globalPosition);
    if (_activeStrokes.isNotEmpty) {
      setState(() {
        _activeStrokes.last.points.add(localPosition);
      });
    }
  }

  /// When child lifts their finger, check if they hit the target accuracy
  /// and automatically complete!
  void _onPanEnd(Size canvasSize) {
    final target = _currentDrawTarget;
    final marginX = canvasSize.width * 0.08;
    final marginY = canvasSize.height * 0.10;
    final bounds = Rect.fromLTWH(
      marginX,
      marginY,
      canvasSize.width - (marginX * 2),
      canvasSize.height - (marginY * 2),
    );

    final paths = TracingGuide.getScaledPaths(target, bounds);
    final checkpoints = TracingGuide.extractCheckpoints(paths);

    final strokePoints = _activeStrokes
        .where((s) => !s.isEraser)
        .map((s) => s.points)
        .toList();

    final eval = TracingGuide.evaluateTracing(
      checkpoints: checkpoints,
      userStrokes: strokePoints,
      hitRadius: 44.0,
    );

    // If child met the accuracy requirement, automatically trigger success!
    if (eval.isSuccess) {
      final alreadyDone = (_drawStage == 1 && _drawStage1Success) ||
          (_drawStage == 2 && _drawStage2Success);
      if (!alreadyDone) {
        _handleTracingSuccess(target);
      }
    }
  }

  void _clearCanvas() {
    AppAudioService.instance.playTapSound();
    setState(() {
      _activeStrokes.clear();
      if (_drawStage == 1) {
        _drawStage1Success = false;
      } else {
        _drawStage2Success = false;
      }
    });
  }

  void _undoCanvas() {
    AppAudioService.instance.playTapSound();
    if (_activeStrokes.isNotEmpty) {
      setState(() {
        _activeStrokes.removeLast();
      });
    }
  }

  void _checkDrawingManual(Size canvasSize) {
    AppAudioService.instance.playTapSound();

    final target = _currentDrawTarget;
    final marginX = canvasSize.width * 0.08;
    final marginY = canvasSize.height * 0.10;
    final bounds = Rect.fromLTWH(
      marginX,
      marginY,
      canvasSize.width - (marginX * 2),
      canvasSize.height - (marginY * 2),
    );

    final paths = TracingGuide.getScaledPaths(target, bounds);
    final checkpoints = TracingGuide.extractCheckpoints(paths);

    final strokePoints = _activeStrokes
        .where((s) => !s.isEraser)
        .map((s) => s.points)
        .toList();

    final eval = TracingGuide.evaluateTracing(
      checkpoints: checkpoints,
      userStrokes: strokePoints,
      hitRadius: 44.0,
    );

    if (eval.totalPoints < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Trace on the dotted lines of "$target" with your finger! 👆',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    if (!eval.isSuccess) {
      final percent = (eval.coverage * 100).toInt();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            percent < 25
                ? 'Trace accurately on the dotted stencil of "$target"! ✏️'
                : 'Almost there! You covered $percent% of "$target". Trace the rest of the lines! ✨',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    _handleTracingSuccess(target);
  }

  void _handleTracingSuccess(String target) {
    AppAudioService.instance.playSuccessChime();

    if (_drawStage == 1) {
      setState(() {
        _drawStage1Success = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Perfect! You traced "$target"! Now trace Step 2!'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.green,
        ),
      );

      // Automatically advance to Step 2 after 1.2s
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          _drawStage = 2;
        });
        AppAudioService.instance.speak('Now trace: $_stage2Word!');
      });
    } else {
      setState(() {
        _drawStage2Success = true;
      });

      _confettiKey.currentState?.play();
      context.read<UserCubit>().addXp(15);
      AppAudioService.instance.speak(
        'Master artist! You traced both $_stage1Symbol and $_stage2Word! 15 stars earned!',
      );
    }
  }

  // -------------------------------------------------------------
  // UI BUILD
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sheetHeight = size.height * 0.90;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ConfettiCelebration(
        key: _confettiKey,
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabSelector(),
            const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
            Expanded(
              child: _currentTab == PracticeTab.voice
                  ? _buildVoicePracticeBody()
                  : _buildDrawPracticeBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.softPurple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryPurple,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Duolingo Kid Practice',
                  style: AppTextStyles.bodySmall(
                    color: AppColors.primaryPurple,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _buildTabPill(
                tab: PracticeTab.voice,
                icon: Icons.mic_rounded,
                label: 'Speak & Spell 🎤',
                selected: _currentTab == PracticeTab.voice,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTabPill(
                tab: PracticeTab.draw,
                icon: Icons.edit_rounded,
                label: 'Trace & Draw ✏️',
                selected: _currentTab == PracticeTab.draw,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required PracticeTab tab,
    required IconData icon,
    required String label,
    required bool selected,
  }) {
    return InkWell(
      onTap: () {
        AppAudioService.instance.playTapSound();
        setState(() {
          _currentTab = tab;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppColors.textMedium,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textMedium,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: 2-STEP SPEAK & SPELL BODY
  // -------------------------------------------------------------
  Widget _buildVoicePracticeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        children: [
          // 2-Step Progress Selector: [ 1️⃣ Say 'A' ] [ 2️⃣ Say 'A for Apple' ]
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStageChip(
                    stageNumber: 1,
                    title: '1. Say "$_stage1Symbol"',
                    isCompleted: _voiceStage1Success,
                    isActive: _voiceStage == 1,
                    onTap: () {
                      AppAudioService.instance.playTapSound();
                      setState(() {
                        _voiceStage = 1;
                        _voiceFeedback = '';
                      });
                      _playCurrentVoicePrompt();
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildStageChip(
                    stageNumber: 2,
                    title: '2. Say "$_stage1Symbol for $_stage2Word"',
                    isCompleted: _voiceStage2Success,
                    isActive: _voiceStage == 2,
                    onTap: () {
                      AppAudioService.instance.playTapSound();
                      setState(() {
                        _voiceStage = 2;
                        _voiceFeedback = '';
                      });
                      _playCurrentVoicePrompt();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Target Concept Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.softPurple.withOpacity(0.7),
                  AppColors.purpleLight.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryPurple.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _voiceStage == 1
                      ? _stage1Symbol
                      : '$_stage1Symbol for $_stage2Word',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _voiceStage == 1 ? 72 : 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryPurple,
                    letterSpacing: _voiceStage == 1 ? 2 : 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentVoicePrompt,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.textMedium,
                  ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    AppAudioService.instance.playTapSound();
                    AppAudioService.instance.speak(_currentVoicePrompt);
                  },
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: const Text('Listen Prompt 🔊'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryPurple,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Big Mic Button with Wave Pulses
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isListening)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 130 + (_pulseController.value * 30),
                        height: 130 + (_pulseController.value * 30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.orange.withOpacity(
                            0.25 - (_pulseController.value * 0.15),
                          ),
                        ),
                      );
                    },
                  ),
                GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [AppColors.orange, Colors.deepOrange]
                            : [AppColors.primaryPurple, const Color(0xFF6C4AB6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                                  ? AppColors.orange
                                  : AppColors.primaryPurple)
                              .withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            _isListening
                ? 'Listening to you... 👂 (Auto-checks when you speak!)'
                : ((_voiceStage == 1 ? _voiceStage1Success : _voiceStage2Success)
                    ? '⭐ You Did It! ⭐'
                    : 'Tap Mic & Say It! 🎙️'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _isListening
                  ? AppColors.orange
                  : ((_voiceStage == 1
                          ? _voiceStage1Success
                          : _voiceStage2Success)
                      ? AppColors.green
                      : AppColors.textDark),
            ),
          ),

          const SizedBox(height: 8),

          // Speech Live Transcript
          if (_recognizedWords.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                'Heard: "$_recognizedWords"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMedium,
                ),
              ),
            ),

          if (_voiceFeedback.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _voiceFeedback.contains('Awesome') ||
                        _voiceFeedback.contains('Superstar')
                    ? AppColors.green.withOpacity(0.12)
                    : AppColors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _voiceFeedback.contains('Awesome') ||
                          _voiceFeedback.contains('Superstar')
                      ? AppColors.green.withOpacity(0.3)
                      : AppColors.orange.withOpacity(0.3),
                ),
              ),
              child: Text(
                _voiceFeedback,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _voiceFeedback.contains('Awesome') ||
                          _voiceFeedback.contains('Superstar')
                      ? AppColors.green
                      : AppColors.textDark,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Manual Fallback Button (Kept for young toddlers who speak softly)
          OutlinedButton.icon(
            onPressed: () => _onVoiceSuccess(
              _voiceStage == 1
                  ? _stage1Symbol
                  : '$_stage1Symbol for $_stage2Word',
            ),
            icon: const Icon(Icons.star_rounded, color: AppColors.orange),
            label: Text(
              _voiceStage == 1
                  ? 'I Said "$_stage1Symbol"! 🌟'
                  : 'I Said "$_stage1Symbol for $_stage2Word"! 🌟 (+15 XP)',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.orange,
              side: const BorderSide(color: AppColors.orange, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: 2-STEP ACCURATE TRACE & DRAW WITH AUTO-CHECK
  // -------------------------------------------------------------
  Widget _buildDrawPracticeBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // 2-Step Stage Chips: [ 1️⃣ Trace 'A' ] [ 2️⃣ Trace 'APPLE' ]
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStageChip(
                        stageNumber: 1,
                        title: '1. Trace "$_stage1Symbol"',
                        isCompleted: _drawStage1Success,
                        isActive: _drawStage == 1,
                        onTap: () {
                          AppAudioService.instance.playTapSound();
                          setState(() {
                            _drawStage = 1;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildStageChip(
                        stageNumber: 2,
                        title: '2. Trace "$_stage2Word"',
                        isCompleted: _drawStage2Success,
                        isActive: _drawStage == 2,
                        onTap: () {
                          AppAudioService.instance.playTapSound();
                          setState(() {
                            _drawStage = 2;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Toolbar: Color Dots, Eraser, Undo, Clear
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  ..._palette.map((color) {
                    final isSelected = !_isEraser && _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        AppAudioService.instance.playTapSound();
                        setState(() {
                          _isEraser = false;
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: isSelected ? 32 : 24,
                        height: isSelected ? 32 : 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.white,
                            width: isSelected ? 3 : 1.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const Spacer(),

                  IconButton(
                    icon: Icon(
                      Icons.auto_fix_normal_rounded,
                      color: _isEraser ? AppColors.orange : AppColors.textMedium,
                      size: 22,
                    ),
                    tooltip: 'Eraser',
                    onPressed: () {
                      AppAudioService.instance.playTapSound();
                      setState(() {
                        _isEraser = !_isEraser;
                      });
                    },
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.undo_rounded,
                      color: AppColors.textMedium,
                      size: 22,
                    ),
                    tooltip: 'Undo',
                    onPressed: _undoCanvas,
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.textMedium,
                      size: 22,
                    ),
                    tooltip: 'Clear',
                    onPressed: _clearCanvas,
                  ),
                ],
              ),
            ),

            // Drawing Canvas Area with Live Stencil Hit-Testing
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF9FF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryPurple.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: LayoutBuilder(
                    builder: (canvasCtx, canvasBox) {
                      final canvasSize = Size(
                        canvasBox.maxWidth,
                        canvasBox.maxHeight,
                      );

                      final marginX = canvasSize.width * 0.08;
                      final marginY = canvasSize.height * 0.10;
                      final bounds = Rect.fromLTWH(
                        marginX,
                        marginY,
                        canvasSize.width - (marginX * 2),
                        canvasSize.height - (marginY * 2),
                      );

                      final target = _currentDrawTarget;
                      final paths = TracingGuide.getScaledPaths(target, bounds);
                      final checkpoints =
                          TracingGuide.extractCheckpoints(paths);

                      final strokePoints = _activeStrokes
                          .where((s) => !s.isEraser)
                          .map((s) => s.points)
                          .toList();

                      final eval = TracingGuide.evaluateTracing(
                        checkpoints: checkpoints,
                        userStrokes: strokePoints,
                        hitRadius: 44.0,
                      );

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            onPanStart: (details) {
                              final box =
                                  canvasCtx.findRenderObject() as RenderBox?;
                              if (box != null) {
                                _onPanStart(details, box);
                              }
                            },
                            onPanUpdate: (details) {
                              final box =
                                  canvasCtx.findRenderObject() as RenderBox?;
                              if (box != null) {
                                _onPanUpdate(details, box);
                              }
                            },
                            onPanEnd: (_) => _onPanEnd(canvasSize),
                            child: CustomPaint(
                              painter: AccurateTracingPainter(
                                targetSymbol: target,
                                paths: paths,
                                checkpoints: checkpoints,
                                hitIndices: eval.hitIndices,
                                strokes: _activeStrokes,
                              ),
                              size: Size.infinite,
                            ),
                          ),

                          // Live Tracing Progress Indicator Banner
                          Positioned(
                            top: 8,
                            left: 12,
                            right: 12,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  child: Text(
                                    'Trace "$target" (Auto-checks!) 👆',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryPurple,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: eval.isSuccess
                                        ? AppColors.greenLight
                                        : Colors.white.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: eval.isSuccess
                                          ? AppColors.green
                                          : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        eval.isSuccess
                                            ? Icons.check_circle_rounded
                                            : Icons.auto_awesome_rounded,
                                        size: 14,
                                        color: eval.isSuccess
                                            ? AppColors.green
                                            : AppColors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Traced: ${(eval.coverage * 100).toInt()}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: eval.isSuccess
                                              ? AppColors.green
                                              : AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Check My Work Button (Also triggers automatically on finger lift when accurate)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Builder(
                builder: (btnCtx) {
                  return AppButton(
                    label: (_drawStage == 1
                            ? _drawStage1Success
                            : _drawStage2Success)
                        ? 'Great Job! 🌟 +15 XP'
                        : 'Check My Work 🎨',
                    variant: (_drawStage == 1
                            ? _drawStage1Success
                            : _drawStage2Success)
                        ? AppButtonVariant.primary
                        : AppButtonVariant.secondary,
                    onPressed: () {
                      final box = context.findRenderObject() as RenderBox?;
                      final size = box?.size ?? const Size(360, 400);
                      _checkDrawingManual(size);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStageChip({
    required int stageNumber,
    required String title,
    required bool isCompleted,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryPurple
              : (isCompleted ? AppColors.greenLight : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : (isActive
                      ? Icons.play_arrow_rounded
                      : Icons.circle_outlined),
              size: 15,
              color: isActive
                  ? Colors.white
                  : (isCompleted ? AppColors.green : AppColors.textMedium),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? Colors.white
                      : (isCompleted ? AppColors.green : AppColors.textMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Represents a single continuous stroke drawn by the child
class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
  });
}

/// CustomPainter for the accurate tracing canvas.
class AccurateTracingPainter extends CustomPainter {
  final String targetSymbol;
  final List<Path> paths;
  final List<Offset> checkpoints;
  final Set<int> hitIndices;
  final List<DrawingStroke> strokes;

  AccurateTracingPainter({
    required this.targetSymbol,
    required this.paths,
    required this.checkpoints,
    required this.hitIndices,
    required this.strokes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Stencil Guide Paths as thick dashed lines
    final stencilPaint = Paint()
      ..color = AppColors.primaryPurple.withOpacity(0.18)
      ..strokeWidth = 22.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final p in paths) {
      canvas.drawPath(p, stencilPaint);
    }

    // 2. Draw Checkpoint Guide Dots along the path
    final unhitDotPaint = Paint()
      ..color = AppColors.primaryPurple.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final hitDotPaint = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = AppColors.green.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < checkpoints.length; i++) {
      final pt = checkpoints[i];
      if (hitIndices.contains(i)) {
        // Glowing hit dot
        canvas.drawCircle(pt, 10.0, glowPaint);
        canvas.drawCircle(pt, 5.0, hitDotPaint);
      } else {
        // Un-hit dot
        canvas.drawCircle(pt, 4.0, unhitDotPaint);
      }
    }

    // 3. Draw Kid's Crayon Strokes
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          stroke.strokeWidth / 2,
          paint..style = PaintingStyle.fill,
        );
      } else {
        final path = Path();
        path.moveTo(stroke.points[0].dx, stroke.points[0].dy);

        for (int i = 0; i < stroke.points.length - 1; i++) {
          final p0 = stroke.points[i];
          final p1 = stroke.points[i + 1];
          final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
          path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
        }
        path.lineTo(stroke.points.last.dx, stroke.points.last.dy);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AccurateTracingPainter oldDelegate) => true;
}
