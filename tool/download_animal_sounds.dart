import 'dart:io';

final Map<String, List<String>> animalSources = {
  'cow': [
    'https://raw.githubusercontent.com/SixStringsCoder/matching_game/master/audio/animals/cow.mp3',
    'https://raw.githubusercontent.com/muammar-yacoob/Animal-Sounds/master/app/src/main/res/raw/cow.mp3',
  ],
  'dog': [
    'https://raw.githubusercontent.com/SixStringsCoder/matching_game/master/audio/animals/dog.mp3',
    'https://raw.githubusercontent.com/muammar-yacoob/Animal-Sounds/master/app/src/main/res/raw/dog.mp3',
  ],
  'cat': [
    'https://cdn.assets.scratch.mit.edu/internalapi/asset/83c36d806dc92327b9e7049a565c6bff.wav/get/',
  ],
  'duck': [
    'https://raw.githubusercontent.com/SixStringsCoder/matching_game/master/audio/animals/duck.mp3',
    'https://raw.githubusercontent.com/muammar-yacoob/Animal-Sounds/master/app/src/main/res/raw/duck.mp3',
  ],
  'elephant': [
    'https://raw.githubusercontent.com/SixStringsCoder/matching_game/master/audio/animals/elephant.mp3',
    'https://raw.githubusercontent.com/muammar-yacoob/Animal-Sounds/master/app/src/main/res/raw/elephant.mp3',
  ],
  'sheep': [
    'https://raw.githubusercontent.com/SixStringsCoder/matching_game/master/audio/animals/sheep.mp3',
    'https://raw.githubusercontent.com/muammar-yacoob/Animal-Sounds/master/app/src/main/res/raw/sheep.mp3',
  ],
  'horse': [
    'https://raw.githubusercontent.com/SixStringsCoder/matching_game/master/audio/animals/horse.mp3',
    'https://raw.githubusercontent.com/muammar-yacoob/Animal-Sounds/master/app/src/main/res/raw/horse.mp3',
  ],
  'rooster': [
    'https://raw.githubusercontent.com/SixStringsCoder/matching_game/master/audio/animals/chicken.mp3',
    'https://raw.githubusercontent.com/muammar-yacoob/Animal-Sounds/master/app/src/main/res/raw/rooster.mp3',
  ],
  'lion': [
    'https://raw.githubusercontent.com/jshsam/ZooApp/master/app/src/main/res/raw/lion.mp3',
    'https://raw.githubusercontent.com/muammar-yacoob/Animal-Sounds/master/app/src/main/res/raw/lion.mp3',
  ],
  'monkey': [
    'https://raw.githubusercontent.com/jshsam/ZooApp/master/app/src/main/res/raw/gorilla.mp3',
    'https://raw.githubusercontent.com/muammar-yacoob/Animal-Sounds/master/app/src/main/res/raw/monkey.mp3',
  ],
  'bird': [
    'https://raw.githubusercontent.com/muammar-yacoob/Animal-Sounds/master/app/src/main/res/raw/bird.mp3',
    'https://raw.githubusercontent.com/Anoofs/AnimalSounds/master/app/src/main/res/raw/sparrow_sound.mp3',
    'https://cdn.assets.scratch.mit.edu/internalapi/asset/79a83d73bdf8e983cf8d45e7f1d4c7a6.wav/get/',
  ],
  'frog': [
    'https://raw.githubusercontent.com/muammar-yacoob/Animal-Sounds/master/app/src/main/res/raw/frog.mp3',
    'https://cdn.assets.scratch.mit.edu/internalapi/asset/c3658ebc087948f95c02db39d0944416.wav/get/',
  ],
};

Future<void> main() async {
  final outDir = Directory('assets/audio/animals');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final client = HttpClient();

  for (final entry in animalSources.entries) {
    final animal = entry.key;
    final urls = entry.value;

    bool downloaded = false;
    for (final url in urls) {
      final ext = url.contains('.wav') ? 'wav' : 'mp3';
      final outFile = File('assets/audio/animals/$animal.$ext');

      try {
        stdout.write('Trying $animal from $url... ');
        final request = await client.getUrl(Uri.parse(url));
        request.headers.set('User-Agent', 'Mozilla/5.0');
        final response = await request.close();

        if (response.statusCode == 200) {
          final bytes = await response.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
          // Verify valid size (> 3000 bytes) and not an HTML error
          final isHtml = bytes.take(15).map((b) => String.fromCharCode(b)).join().toLowerCase().contains('<!doctype') ||
                         bytes.take(15).map((b) => String.fromCharCode(b)).join().toLowerCase().contains('<html');
          if (bytes.length > 3000 && !isHtml) {
            outFile.writeAsBytesSync(bytes);
            stdout.writeln('SUCCESS (${(bytes.length / 1024).toStringAsFixed(1)} KB) -> ${outFile.path}');
            downloaded = true;
            break;
          } else {
            stdout.writeln('Invalid payload (size=${bytes.length}, isHtml=$isHtml)');
          }
        } else {
          stdout.writeln('HTTP ${response.statusCode}');
        }
      } catch (e) {
        stdout.writeln('Error: $e');
      }
    }

    if (!downloaded) {
      stdout.writeln('WARNING: Could not download audio for $animal');
    }
  }

  client.close();
  stdout.writeln('\nFinished processing all animal audio files.');
}
