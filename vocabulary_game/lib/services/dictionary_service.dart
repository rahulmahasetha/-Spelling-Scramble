import 'package:flutter/services.dart' show rootBundle;

class DictionaryService {
  static final DictionaryService _instance = DictionaryService._internal();
  factory DictionaryService() => _instance;

  DictionaryService._internal();

  Set<String> _dictionary = {};
  bool _isLoaded = false;

  Future<void> loadDictionary() async {
    if (_isLoaded) return; // Load only once
    try {
      final String contents = await rootBundle.loadString('assets/words_alpha.txt');
      _dictionary = contents.split('\n').map((word) => word.trim().toLowerCase()).toSet();
      _isLoaded = true;
      print('Dictionary loaded successfully. Total words: ${_dictionary.length}');
    } catch (e) {
      print('Error loading dictionary: $e');
      // Handle error, e.g., show a dialog to the user
    }
  }

  bool isValidWord(String word) {
    if (!_isLoaded) {
      print('Dictionary not loaded. Cannot validate word.');
      return false;
    }
    return _dictionary.contains(word.toLowerCase());
  }
}