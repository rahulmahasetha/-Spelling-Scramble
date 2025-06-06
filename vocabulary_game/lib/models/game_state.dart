// lib/models/game_state.dart
import 'package:flutter/foundation.dart';
//import 'package:vocabulary_game/utils/constants.dart'; // Ensure this is imported

class GameState with ChangeNotifier {
  int _score = 0;
  int _round = 0;
  String _currentFixedLetter = '';
  List<String> _currentAvailableLetters = [];
  String _currentAttempt = '';
  String _gameMessage = 'Form a word!';
  bool _isCorrectAttempt = true;
  int _currentWordLength = 0; // NEW: To store the word length for the current round

  int get score => _score;
  int get round => _round;
  String get currentFixedLetter => _currentFixedLetter;
  List<String> get currentAvailableLetters => _currentAvailableLetters;
  String get currentAttempt => _currentAttempt;
  String get gameMessage => _gameMessage;
  bool get isCorrectAttempt => _isCorrectAttempt;
  int get currentWordLength => _currentWordLength; // NEW: Getter for dynamic word length

  void resetGame() {
    _score = 0;
    _round = 0;
    _currentFixedLetter = '';
    _currentAvailableLetters = [];
    _currentAttempt = '';
    _gameMessage = 'Form a word!';
    _isCorrectAttempt = true;
    _currentWordLength = 0; // Reset on game start
    notifyListeners();
  }

  void incrementRound() {
    _round++;
    notifyListeners();
  }

  void addScore(int points) {
    _score += points;
    notifyListeners();
  }

  void deductScore(int points) {
    _score -= points;
    if (_score < 0) _score = 0;
    notifyListeners();
  }

  void setupRoundLetters({required String fixedLetter, required List<String> availableLetters}) {
    _currentFixedLetter = fixedLetter;
    _currentAvailableLetters = availableLetters;
    notifyListeners();
  }

  void setWordLengthForRound(int length) { // NEW: Setter for dynamic word length
    _currentWordLength = length;
    notifyListeners();
  }

  void updateAttempt(String letter, {bool removeLast = false}) {
    if (removeLast) {
      if (_currentAttempt.isNotEmpty) {
        _currentAttempt = _currentAttempt.substring(0, _currentAttempt.length - 1);
      }
    } else {
      // Use dynamic word length for attempt validation
      if (_currentAttempt.length < _currentWordLength) {
        _currentAttempt += letter;
      }
    }
    notifyListeners();
  }

  void clearAttempt() {
    _currentAttempt = '';
    notifyListeners();
  }

  void setGameMessage(String message, {bool isCorrect = true}) {
    _gameMessage = message;
    _isCorrectAttempt = isCorrect;
    notifyListeners();
  }
}