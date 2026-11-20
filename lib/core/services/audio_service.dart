import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AppAudioService {
  static final AppAudioService instance = AppAudioService._internal();

  AppAudioService._internal();

  FlutterTts? _tts;
  AudioPlayer? _sfxPlayer;

  bool soundEnabled = true;
  bool musicEnabled = true;
  bool _isTtsInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  void _ensureInitialized() {
    if (_tts == null) {
      try {
        _tts = FlutterTts();
        _initTts();
      } catch (_) {
        _isTtsInitialized = false;
      }
    }
    if (_sfxPlayer == null) {
      try {
        _sfxPlayer = AudioPlayer();
      } catch (_) {}
    }
  }

  Future<void> _initTts() async {
    try {
      if (_tts == null) return;
      await _tts!.setLanguage('en-US');
      await _tts!.setSpeechRate(0.42); // Calm, clear tempo for young kids
      await _tts!.setPitch(1.2); // Cheerful child-friendly pitch
      await _tts!.awaitSpeakCompletion(true);

      _tts!.setStartHandler(() {
        _isSpeaking = true;
      });

      _tts!.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _tts!.setErrorHandler((dynamic msg) {
        _isSpeaking = false;
      });

      _isTtsInitialized = true;
    } catch (_) {
      _isTtsInitialized = false;
    }
  }

  /// Speaks educational text with natural TTS synthesizer
  Future<void> speak(
    String text, {
    double pitch = 1.2,
    double rate = 0.42,
  }) async {
    if (!soundEnabled) return;
    try {
      _ensureInitialized();
      if (!_isTtsInitialized) {
        await _initTts();
      }
      if (_tts != null) {
        await _tts!.setPitch(pitch);
        await _tts!.setSpeechRate(rate);
        _isSpeaking = true;
        await _tts!.speak(text);
      }
    } catch (_) {
      _isSpeaking = false;
    }
  }

  /// Stops current speech and audio effects
  Future<void> stop() async {
    try {
      await _tts?.stop();
      await _sfxPlayer?.stop();
      _isSpeaking = false;
    } catch (_) {}
  }

  static const Map<String, String> animalSoundAssets = {
    'cow': 'audio/animals/cow.mp3',
    'cat': 'audio/animals/cat.wav',
    'kitten': 'audio/animals/cat.wav',
    'dog': 'audio/animals/dog.mp3',
    'puppy': 'audio/animals/dog.mp3',
    'lion': 'audio/animals/lion.mp3',
    'tiger': 'audio/animals/lion.mp3',
    'duck': 'audio/animals/duck.mp3',
    'sheep': 'audio/animals/sheep.mp3',
    'lamb': 'audio/animals/sheep.mp3',
    'elephant': 'audio/animals/elephant.mp3',
    'horse': 'audio/animals/horse.mp3',
    'pony': 'audio/animals/horse.mp3',
    'monkey': 'audio/animals/monkey.mp3',
    'gorilla': 'audio/animals/monkey.mp3',
    'ape': 'audio/animals/monkey.mp3',
    'rooster': 'audio/animals/rooster.mp3',
    'chicken': 'audio/animals/rooster.mp3',
    'hen': 'audio/animals/rooster.mp3',
    'bird': 'audio/animals/bird.wav',
    'sparrow': 'audio/animals/bird.wav',
    'parrot': 'audio/animals/bird.wav',
    'bluebird': 'audio/animals/bird.wav',
    'peacock': 'audio/animals/bird.wav',
    'pigeon': 'audio/animals/bird.wav',
    'hummingbird': 'audio/animals/bird.wav',
    'toucan': 'audio/animals/bird.wav',
    'owl': 'audio/animals/owl.wav',
    'frog': 'audio/animals/frog.wav',
    'toad': 'audio/animals/frog.wav',
  };

  /// Plays authentic real animal sound recordings (real cow moo, real cat meow, etc.)
  Future<void> playAnimalSound(String animal) async {
    if (!soundEnabled) return;

    final lower = animal.toLowerCase().trim();
    String? assetPath;
    for (final entry in animalSoundAssets.entries) {
      if (lower.contains(entry.key)) {
        assetPath = entry.value;
        break;
      }
    }

    if (assetPath != null) {
      try {
        _ensureInitialized();
        _isSpeaking = true;
        await _sfxPlayer?.stop();
        await _sfxPlayer?.play(AssetSource(assetPath));
        Future.delayed(const Duration(milliseconds: 1800), () {
          _isSpeaking = false;
        });
        return;
      } catch (_) {
        // Fallback for headless environments or unsupported audio driver
      }
    }

    // Fallback for animals without a dedicated recording: speak the animal name clearly
    await speak(animal);
  }

  /// Pleasant tactile button tap sound
  Future<void> playTapSound() async {
    if (!soundEnabled) return;
    await _playWaveSfx(frequency: 520, durationMs: 60, type: _WaveType.sine);
  }

  /// Card flip whoosh
  Future<void> playCardFlipSound() async {
    if (!soundEnabled) return;
    await _playWaveSfx(
      frequency: 440,
      durationMs: 80,
      type: _WaveType.triangle,
    );
  }

  /// Cheerful success chime (Ascending major triad)
  Future<void> playSuccessChime() async {
    if (!soundEnabled) return;
    await _playArpeggio([523.25, 659.25, 783.99, 1046.50], 80);
  }

  /// Victory fanfare with celebration
  Future<void> playCelebrationFanfare() async {
    if (!soundEnabled) return;
    await _playArpeggio([523.25, 659.25, 783.99, 1046.50, 1318.51], 100);
  }

  /// Gentle soft bonk for incorrect attempt
  Future<void> playIncorrectSound() async {
    if (!soundEnabled) return;
    await _playArpeggio([380.0, 320.0, 260.0], 100);
  }

  // --- In-Memory PCM WAV Synthesis Engine ---

  Future<void> _playWaveSfx({
    required double frequency,
    required int durationMs,
    required _WaveType type,
  }) async {
    try {
      _ensureInitialized();
      if (_sfxPlayer == null) return;
      final wavBytes = _generateWavBytes(
        frequencies: [frequency],
        durationMs: durationMs,
        type: type,
      );
      await _sfxPlayer!.play(BytesSource(wavBytes));
    } catch (_) {}
  }

  Future<void> _playArpeggio(List<double> notes, int noteDurationMs) async {
    try {
      _ensureInitialized();
      if (_sfxPlayer == null) return;
      final wavBytes = _generateWavBytes(
        frequencies: notes,
        durationMs: noteDurationMs,
        type: _WaveType.sine,
      );
      await _sfxPlayer!.play(BytesSource(wavBytes));
    } catch (_) {}
  }

  Uint8List _generateWavBytes({
    required List<double> frequencies,
    required int durationMs,
    required _WaveType type,
  }) {
    const int sampleRate = 22050;
    final int samplesPerNote = ((durationMs / 1000.0) * sampleRate).toInt();
    final int totalSamples = samplesPerNote * frequencies.length;
    final int dataSize = totalSamples * 2; // 16-bit mono
    final int fileSize = 44 + dataSize;

    final buffer = ByteData(fileSize);

    // RIFF chunk descriptor
    buffer.setUint8(0, 0x52); // 'R'
    buffer.setUint8(1, 0x49); // 'I'
    buffer.setUint8(2, 0x46); // 'F'
    buffer.setUint8(3, 0x46); // 'F'
    buffer.setUint32(4, fileSize - 8, Endian.little);
    buffer.setUint8(8, 0x57); // 'W'
    buffer.setUint8(9, 0x41); // 'A'
    buffer.setUint8(10, 0x56); // 'V'
    buffer.setUint8(11, 0x45); // 'E'

    // "fmt " sub-chunk
    buffer.setUint8(12, 0x66); // 'f'
    buffer.setUint8(13, 0x6D); // 'm'
    buffer.setUint8(14, 0x74); // 't'
    buffer.setUint8(15, 0x20); // ' '
    buffer.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    buffer.setUint16(20, 1, Endian.little); // AudioFormat (1 for PCM)
    buffer.setUint16(22, 1, Endian.little); // NumChannels (1 mono)
    buffer.setUint32(24, sampleRate, Endian.little); // SampleRate
    buffer.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    buffer.setUint16(32, 2, Endian.little); // BlockAlign
    buffer.setUint16(34, 16, Endian.little); // BitsPerSample

    // "data" sub-chunk
    buffer.setUint8(36, 0x64); // 'd'
    buffer.setUint8(37, 0x61); // 'a'
    buffer.setUint8(38, 0x74); // 't'
    buffer.setUint8(39, 0x61); // 'a'
    buffer.setUint32(40, dataSize, Endian.little);

    // Generate Audio Waves
    int sampleIndex = 0;
    for (final freq in frequencies) {
      for (int i = 0; i < samplesPerNote; i++) {
        final double t = i / sampleRate;
        double wave = 0.0;
        final double phase = (2 * pi * freq * t) % (2 * pi);

        switch (type) {
          case _WaveType.sine:
            wave = sin(phase);
            break;
          case _WaveType.triangle:
            wave = (2 / pi) * asin(sin(phase));
            break;
          case _WaveType.square:
            wave = sin(phase) >= 0 ? 0.7 : -0.7;
            break;
          case _WaveType.sawtooth:
            wave = (2 * (phase / (2 * pi))) - 1.0;
            break;
        }

        // Apply smooth envelope to prevent clicking
        final double envelope = sin((i / samplesPerNote) * pi);
        final int sampleValue = (wave * envelope * 24000).toInt().clamp(
          -32768,
          32767,
        );

        buffer.setInt16(44 + (sampleIndex * 2), sampleValue, Endian.little);
        sampleIndex++;
      }
    }

    return buffer.buffer.asUint8List();
  }
}

enum _WaveType { sine, triangle, square, sawtooth }
