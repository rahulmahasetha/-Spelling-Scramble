// lib/utils/game_logic_helper.dart
import 'package:vocabulary_game/utils/word_generator.dart'; // Make sure this is imported

class GameLogicHelper {
  // This method doesn't need to know the 'correctWordLength' anymore,
  // as the length check is done in GameScreen's _submitWord.
  static bool isValidSubmission(String submittedWord, String fixedLetter) {
    // 1. Check if the submitted word is in the dictionary
    if (!WordGenerator.isValidWord(submittedWord.toLowerCase())) {
      return false;
    }

    // 2. The word must contain the fixed letter (already checked in GameScreen)
    // This check is robust, so keep it for any future direct calls to this helper.
    if (!submittedWord.toLowerCase().contains(fixedLetter.toLowerCase())) {
      return false;
    }

    return true;
  }
}