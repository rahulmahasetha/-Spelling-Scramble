// lib/utils/word_generator.dart
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

class WordGenerator {
  static Map<int, Map<String, List<String>>> _dictionary = {};
  static final Random _random = Random();

  static const String _commonLetters = 'ETAOINSHRDLUCMFWYGPVBKJXQZ';

  static Future<void> loadDictionary() async {
    if (_dictionary.isNotEmpty) {
      return;
    }
    final String fileContent = await rootBundle.loadString(
      'assets/words_alpha.txt',
    );
    final List<String> lines = fileContent.split('\n');

    for (var length in [3, 4, 5]) {
      _dictionary[length] = {};
    }

    for (String line in lines) {
      final String word = line.trim().toLowerCase();
      if (word.isEmpty) continue;

      if (word.length >= 3 && word.length <= 5) {
        final String firstLetter = word[0];
        _dictionary[word.length]!.putIfAbsent(firstLetter, () => []).add(word);
      }
    }
    print('Dictionary loaded. Contains ${lines.length} words.');
    _dictionary.forEach((length, startingLetters) {
      int count = 0;
      startingLetters.forEach((letter, words) {
        count += words.length;
      });
      print('  Length $length: $count words');
    });
  }

  // NEW METHOD: Checks if a word exists in the loaded dictionary
  static bool isValidWord(String word) {
    if (word.isEmpty || word.length < 3 || word.length > 5) {
      return false; // Only valid words are 3, 4, or 5 letters long as per our dictionary loading
    }
    final String firstLetter = word[0];
    return _dictionary[word.length]?[firstLetter]?.contains(word) ?? false;
  }

  static Map<String, dynamic> generateRoundLetters(int wordLength) {
    if (_dictionary.isEmpty) {
      throw Exception("Dictionary not loaded! Call loadDictionary() first.");
    }

    String chosenWord = '';
    String fixedLetter = '';

    int attempts = 0;
    const int maxAttempts = 100;
    while (chosenWord.isEmpty && attempts < maxAttempts) {
      fixedLetter = _commonLetters[_random.nextInt(_commonLetters.length)]
          .toLowerCase();

      final List<String>? wordsByLengthAndFixedLetter =
          _dictionary[wordLength]?[fixedLetter];

      if (wordsByLengthAndFixedLetter != null &&
          wordsByLengthAndFixedLetter.isNotEmpty) {
        wordsByLengthAndFixedLetter.shuffle(_random);
        chosenWord =
            wordsByLengthAndFixedLetter[_random.nextInt(
              wordsByLengthAndFixedLetter.length,
            )];
      }
      attempts++;
    }

    if (chosenWord.isEmpty) {
      print(
        'WARNING: Could not find a suitable word after $maxAttempts attempts. Defaulting to a simple word.',
      );
      // Fallback words: ensure they are lowercase and match expected lengths
      if (wordLength == 3) {
        chosenWord = "cat";
        fixedLetter = "c";
      } else if (wordLength == 4) {
        chosenWord = "read";
        fixedLetter = "r";
      } else if (wordLength == 5) {
        chosenWord = "apple";
        fixedLetter = "a";
      } else {
        // Default to a safe word
        chosenWord = "dog";
        fixedLetter = "d";
      }
    }

    final List<String> availableLetters = [];
    final List<String> lettersFromChosenWord = chosenWord.split('');

    availableLetters.add(fixedLetter);

    for (int i = 1; i < lettersFromChosenWord.length; i++) {
      availableLetters.add(lettersFromChosenWord[i]);
    }

    const int totalAvailableLetters = 10;
    final Set<String> currentLettersSet = availableLetters.toSet();

    while (availableLetters.length < totalAvailableLetters) {
      String randomChar = _commonLetters[_random.nextInt(_commonLetters.length)]
          .toLowerCase();
      if (!currentLettersSet.contains(randomChar)) {
        availableLetters.add(randomChar);
        currentLettersSet.add(randomChar);
      }
    }

    final String actualFixedLetter = availableLetters[0];
    final List<String> lettersToShuffle = availableLetters.sublist(1);
    lettersToShuffle.shuffle(_random);
    availableLetters.setRange(1, availableLetters.length, lettersToShuffle);

    print('Chosen word for length $wordLength: "$chosenWord"');
    print('Fixed letter: "$actualFixedLetter"');
    print(
      'Generated available letters: ${availableLetters.map((l) => l.toUpperCase()).join(', ')}',
    );

    return {
      'fixedLetter': actualFixedLetter,
      'availableLetters': availableLetters,
    };
  }
}
