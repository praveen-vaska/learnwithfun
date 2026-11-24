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

/// Interactive Practice Sheet for Kids (Duolingo Style)
/// Features:
/// 1. Voice Practice: "Speak & Spell" 🎤 (Kid speaks, app listens, celebrates)
/// 2. Trace & Draw: ✏️ (Dotted stencil guide, finger crayon drawing, validation)
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
  stt.SpeechToText? _speech;
  bool _speechAvailable = false;
  bool _isListening = false;
  String _recognizedWords = '';
  bool _voiceSuccess = false;
  String _voiceFeedback = '';

  // --- Drawing State ---
  final List<DrawingStroke> _strokes = [];
  Color _selectedColor = AppColors.primaryPurple;
  final double _strokeWidth = 10.0;
  bool _isEraser = false;
  bool _drawingSuccess = false;

  final List<Color> _palette = const [
    AppColors.primaryPurple,
    AppColors.orange,
    AppColors.yellow,
    AppColors.green,
    AppColors.skyBlue,
    AppColors.pinkDark,
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _initSpeechRecognizer();
    _playWelcomePrompt();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stopListening();
    super.dispose();
  }

  String get _targetSymbol {
    final title = widget.lesson.title.trim();
    if (title.startsWith('Letter ')) {
      return title.replaceAll('Letter ', '').trim();
    }
    if (title.startsWith('Number ')) {
      return title.replaceAll('Number ', '').trim();
    }
    if (widget.lesson.conceptWord.isNotEmpty) {
      return widget.lesson.conceptWord;
    }
    return title;
  }

  String get _promptSentence {
    final symbol = _targetSymbol;
    final concept = widget.lesson.conceptWord;
    if (widget.lesson.categoryId == 'cat_alphabets') {
      return 'Say: $symbol for $concept!';
    } else if (widget.lesson.categoryId == 'cat_numbers') {
      return 'Say: $symbol, $concept!';
    } else if (widget.lesson.categoryId == 'cat_animals') {
      return 'Say: ${widget.lesson.title}! ${widget.lesson.soundText}';
    } else {
      return 'Say: $concept!';
    }
  }

  Future<void> _playWelcomePrompt() async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    AppAudioService.instance.speak(_promptSentence);
  }

  // -------------------------------------------------------------
  // SPEECH RECOGNITION (Voice Practice)
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
      // Toddler fallback: auto-listen simulation
      setState(() {
        _isListening = true;
        _recognizedWords = 'Listening to your sweet voice...';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _onVoiceSuccess(widget.lesson.conceptWord);
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

  void _evaluateSpeech(String words) {
    final lower = words.toLowerCase().trim();
    final targetLower = _targetSymbol.toLowerCase().trim();
    final conceptLower = widget.lesson.conceptWord.toLowerCase().trim();
    final titleLower = widget.lesson.title.toLowerCase().trim();

    // Check if kid said the target letter, word, or sound
    final isMatch = lower.contains(targetLower) ||
        lower.contains(conceptLower) ||
        lower.contains(titleLower) ||
        lower.length >= 2;

    if (isMatch && !_voiceSuccess) {
      _onVoiceSuccess(words);
    }
  }

  void _onVoiceSuccess(String spokenText) {
    _stopListening();
    setState(() {
      _voiceSuccess = true;
      _voiceFeedback = 'Awesome! You said: "$spokenText" 🌟';
    });

    AppAudioService.instance.playSuccessChime();
    _confettiKey.currentState?.play();
    context.read<UserCubit>().addXp(15);
    AppAudioService.instance.speak('Terrific job! You earned 15 stars!');
  }

  // -------------------------------------------------------------
  // TRACING & DRAWING (Canvas Practice)
  // -------------------------------------------------------------
  void _onPanStart(DragStartDetails details, RenderBox box) {
    final localPosition = box.globalToLocal(details.globalPosition);
    setState(() {
      _strokes.add(
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
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.last.points.add(localPosition);
      });
    }
  }

  void _clearCanvas() {
    AppAudioService.instance.playTapSound();
    setState(() {
      _strokes.clear();
      _drawingSuccess = false;
    });
  }

  void _undoCanvas() {
    AppAudioService.instance.playTapSound();
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
      });
    }
  }

  void _checkDrawing() {
    int totalPoints = 0;
    for (final s in _strokes) {
      if (!s.isEraser) {
        totalPoints += s.points.length;
      }
    }

    if (totalPoints < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draw or trace on the stencil with your finger! 🎨'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    AppAudioService.instance.playSuccessChime();
    _confettiKey.currentState?.play();
    setState(() {
      _drawingSuccess = true;
    });
    context.read<UserCubit>().addXp(15);
    AppAudioService.instance.speak('Beautiful drawing! 15 stars for you!');
  }

  // -------------------------------------------------------------
  // UI BUILD
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sheetHeight = size.height * 0.88;

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
            // Top Drag Handle & Close
            _buildHeader(context),

            // Tab Selector: [ 🎤 Speak & Spell ] [ ✏️ Trace & Draw ]
            _buildTabSelector(),

            const Divider(height: 1, thickness: 1, color: AppColors.borderLight),

            // Tab Body
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
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
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
  // TAB 1: SPEAK & SPELL
  // -------------------------------------------------------------
  Widget _buildVoicePracticeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          // Target Concept Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                  _targetSymbol,
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryPurple,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.lesson.conceptWord,
                  style: AppTextStyles.heading1().copyWith(
                    color: AppColors.textDark,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _promptSentence,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.textMedium,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    AppAudioService.instance.playTapSound();
                    AppAudioService.instance.speak(_promptSentence);
                  },
                  icon: const Icon(Icons.volume_up_rounded, size: 20),
                  label: const Text('Listen Again 🔊'),
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

          const SizedBox(height: 28),

          // Big Mic Action Button with Pulsing Wave Animation
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isListening)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 140 + (_pulseController.value * 30),
                        height: 140 + (_pulseController.value * 30),
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
                    width: 110,
                    height: 110,
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
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            _isListening
                ? 'Listening to you... 👂'
                : (_voiceSuccess ? '⭐ You Did It! ⭐' : 'Tap Mic & Say It! 🎙️'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isListening
                  ? AppColors.orange
                  : (_voiceSuccess ? AppColors.green : AppColors.textDark),
            ),
          ),

          const SizedBox(height: 10),

          // Speech Feedback or Live Transcription
          if (_recognizedWords.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.green.withOpacity(0.3)),
              ),
              child: Text(
                _voiceFeedback,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Toddler Friendly Instant Encouragement Button
          OutlinedButton.icon(
            onPressed: () => _onVoiceSuccess(widget.lesson.conceptWord),
            icon: const Icon(Icons.star_rounded, color: AppColors.orange),
            label: const Text('I Said It! 🌟 (+15 XP)'),
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
  // TAB 2: TRACE & DRAW
  // -------------------------------------------------------------
  Widget _buildDrawPracticeBody() {
    final GlobalKey canvasKey = GlobalKey();

    return Column(
      children: [
        // Top Toolbar: Colors, Eraser, Undo, Clear
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Crayon Color Dots
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
                    width: isSelected ? 34 : 26,
                    height: isSelected ? 34 : 26,
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

              // Eraser Toggle
              IconButton(
                icon: Icon(
                  Icons.auto_fix_normal_rounded,
                  color: _isEraser ? AppColors.orange : AppColors.textMedium,
                  size: 24,
                ),
                tooltip: 'Eraser',
                onPressed: () {
                  AppAudioService.instance.playTapSound();
                  setState(() {
                    _isEraser = !_isEraser;
                  });
                },
              ),

              // Undo
              IconButton(
                icon: const Icon(
                  Icons.undo_rounded,
                  color: AppColors.textMedium,
                  size: 24,
                ),
                tooltip: 'Undo',
                onPressed: _undoCanvas,
              ),

              // Clear
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textMedium,
                  size: 24,
                ),
                tooltip: 'Clear',
                onPressed: _clearCanvas,
              ),
            ],
          ),
        ),

        // Drawing Canvas with Dotted Stencil Background
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7FE),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryPurple.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Dotted Stencil Guide in Background
                  Center(
                    child: Opacity(
                      opacity: 0.18,
                      child: Text(
                        _targetSymbol,
                        style: const TextStyle(
                          fontSize: 180,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),

                  // 2. Kid Interactive Drawing Surface
                  Builder(
                    builder: (canvasContext) {
                      return GestureDetector(
                        onPanStart: (details) {
                          final box =
                              canvasKey.currentContext?.findRenderObject()
                                  as RenderBox?;
                          if (box != null) {
                            _onPanStart(details, box);
                          }
                        },
                        onPanUpdate: (details) {
                          final box =
                              canvasKey.currentContext?.findRenderObject()
                                  as RenderBox?;
                          if (box != null) {
                            _onPanUpdate(details, box);
                          }
                        },
                        child: CustomPaint(
                          key: canvasKey,
                          painter: StencilDrawingPainter(strokes: _strokes),
                          size: Size.infinite,
                        ),
                      );
                    },
                  ),

                  // Helper instructions pill at top of canvas
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          'Trace "$_targetSymbol" with your finger! 👆',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom Action Bar: "Check My Work 🎨"
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: AppButton(
            label: _drawingSuccess ? 'Great Job! 🌟 +15 XP' : 'Check My Work 🎨',
            variant: _drawingSuccess
                ? AppButtonVariant.primary
                : AppButtonVariant.secondary,
            onPressed: _checkDrawing,
          ),
        ),
      ],
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

/// Paints the finger strokes on the canvas with smooth quadratic curves
class StencilDrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  StencilDrawingPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
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
  bool shouldRepaint(covariant StencilDrawingPainter oldDelegate) => true;
}
