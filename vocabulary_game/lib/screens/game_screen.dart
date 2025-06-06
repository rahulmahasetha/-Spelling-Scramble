import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:vocabulary_game/models/game_state.dart';
import 'package:vocabulary_game/screens/game_over_screen.dart';
import 'package:vocabulary_game/utils/constants.dart';
import 'package:vocabulary_game/utils/word_generator.dart';
import 'package:vocabulary_game/utils/game_logic_helper.dart';
import 'package:vocabulary_game/widgets/letter_box.dart'; 
import 'package:vocabulary_game/services/audio_service.dart';
import 'package:vocabulary_game/widgets/game_instructions_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Timer _roundTimer;
  int _currentRoundTime = AppConstants.ROUND_TIME_SECONDS;
  List<bool> _letterUsedStatus = List.filled(
    AppConstants.TOTAL_AVAILABLE_LETTERS,
    false,
  );
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _roundTimer = Timer(const Duration(seconds: 0), () {});
    _initGame();
  }

  void _initGame() {
    Future.microtask(() async {
      final gameState = Provider.of<GameState>(context, listen: false);
      await WordGenerator.loadDictionary();
      gameState.resetGame();
      _startNewRound();
    });
  }

  int _getWordLengthForRound(int round) {
    if (round >= 1 && round <= 3) {
      return 3;
    } else if (round >= 4 && round <= 7) {
      return 4;
    } else if (round >= 8 && round <= 10) {
      return 5;
    }
    return 3;
  }

  void _startNewRound() {
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.incrementRound();

    final int currentWordLength = _getWordLengthForRound(gameState.round);
    gameState.setWordLengthForRound(currentWordLength);

    gameState.clearAttempt();
    gameState.setGameMessage('Form a $currentWordLength-letter word!');

    final roundLetters = WordGenerator.generateRoundLetters(currentWordLength);
    gameState.setupRoundLetters(
      fixedLetter: roundLetters['fixedLetter'],
      availableLetters: roundLetters['availableLetters'].cast<String>(),
    );

    // Reset letter used status for the new round
    _letterUsedStatus = List.filled(
      AppConstants.TOTAL_AVAILABLE_LETTERS,
      false,
    );
    _currentRoundTime = AppConstants.ROUND_TIME_SECONDS;
    _startRoundTimer();
  }

  void _startRoundTimer() {
    _roundTimer.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        _roundTimer.cancel();
        return;
      }
      setState(() {
        if (_currentRoundTime > 0) {
          _currentRoundTime--;
        } else {
          _roundTimer.cancel();
          _handleTimeUp();
        }
      });
    });
  }

  void _handleTimeUp() {
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.setGameMessage(
      'Time\'s Up! Penalty -${AppConstants.INCORRECT_PENALTY} points.',
      isCorrect: false,
    );
    _audioService.playSfx('assets/audio/incorrect_answer.wav');
    _showMessageDialog(
      gameState.gameMessage,
      isCorrect: gameState.isCorrectAttempt,
    ).then((_) {
      gameState.deductScore(AppConstants.INCORRECT_PENALTY);
      _nextRound();
    });
  }

  void _onLetterTap(String letter, int index) {
    final gameState = Provider.of<GameState>(context, listen: false);
    final int currentWordLength = gameState.currentWordLength;

    final int fixedLetterIndexInAvailable = 0;

    if (letter.isEmpty) {
      return;
    }

    if (gameState.currentAttempt.isEmpty) {
      if (index == fixedLetterIndexInAvailable) {
        gameState.updateAttempt(letter);
        setState(() {
          _letterUsedStatus[index] = true;
        });
        gameState.setGameMessage(
          'Now add ${currentWordLength - 1} more letters!',
          isCorrect: true,
        );
      } else {
        gameState.setGameMessage(
          'First letter MUST be the fixed letter "${gameState.currentFixedLetter.toUpperCase()}"!',
          isCorrect: false,
        );
        _audioService.playSfx('assets/audio/incorrect_answer.wav', volume: 0.7);
        _showMessageDialog(
          gameState.gameMessage,
          isCorrect: gameState.isCorrectAttempt,
        );
      }
      return;
    }

    if (_letterUsedStatus[index]) {
      return;
    }

    if (gameState.currentAttempt.length < currentWordLength) {
      gameState.updateAttempt(letter);
      setState(() {
        _letterUsedStatus[index] = true;
      });
      if (gameState.currentAttempt.length < currentWordLength) {
        gameState.setGameMessage(
          'Add ${currentWordLength - gameState.currentAttempt.length} more letters.',
          isCorrect: true,
        );
      } else {
        gameState.setGameMessage(
          'Word is $currentWordLength letters. Submit or remove.',
          isCorrect: true,
        );
      }
    }
  }

  void _removeLastLetter() {
    final gameState = Provider.of<GameState>(context, listen: false);
    final int currentWordLength = gameState.currentWordLength;

    if (gameState.currentAttempt.isNotEmpty) {
      String lastLetterInAttempt =
          gameState.currentAttempt[gameState.currentAttempt.length - 1];

      bool letterSuccessfullyUnmarked = false;
      for (int i = gameState.currentAvailableLetters.length - 1; i >= 0; i--) {
        if (_letterUsedStatus[i] &&
            gameState.currentAvailableLetters[i].toUpperCase() ==
                lastLetterInAttempt.toUpperCase()) {
          if (i == 0 && gameState.currentAttempt.length > 1) {
            continue;
          }
          setState(() {
            _letterUsedStatus[i] = false;
          });
          letterSuccessfullyUnmarked = true;
          break;
        }
      }

      if (gameState.currentAttempt.length == 1 &&
          gameState.currentAttempt.toUpperCase() ==
              gameState.currentFixedLetter.toUpperCase() &&
          _letterUsedStatus[0] == true) {
        setState(() {
          _letterUsedStatus[0] = false;
        });
        letterSuccessfullyUnmarked = true;
      }

      gameState.updateAttempt('', removeLast: true);

      if (gameState.currentAttempt.isEmpty) {
        gameState.setGameMessage(
          'First letter MUST be the fixed letter "${gameState.currentFixedLetter.toUpperCase()}"!',
          isCorrect: false,
        );
      } else {
        gameState.setGameMessage(
          'Add ${currentWordLength - gameState.currentAttempt.length} more letters.',
          isCorrect: true,
        );
      }
    }
  }

  void _submitWord() {
    final gameState = Provider.of<GameState>(context, listen: false);
    final String submittedWord = gameState.currentAttempt;
    final String fixedLetter = gameState.currentFixedLetter;
    final int currentWordLength = gameState.currentWordLength;

    _roundTimer.cancel();

    if (submittedWord.length != currentWordLength) {
      gameState.setGameMessage(
        'Word must be $currentWordLength letters long!',
        isCorrect: false,
      );
      _audioService.playSfx('assets/audio/incorrect_answer.wav', volume: 0.7);
      _showMessageDialog(
        gameState.gameMessage,
        isCorrect: gameState.isCorrectAttempt,
      ).then((_) {
        if (_currentRoundTime > 0) _startRoundTimer();
      });
      return;
    }

    if (!submittedWord.toLowerCase().contains(fixedLetter.toLowerCase())) {
      gameState.setGameMessage(
        'Word must contain the fixed letter "${fixedLetter.toUpperCase()}"!',
        isCorrect: false,
      );
      gameState.deductScore(AppConstants.INCORRECT_PENALTY);
      _audioService.playSfx('assets/audio/incorrect_answer.wav');
      _showMessageDialog(
        gameState.gameMessage,
        isCorrect: gameState.isCorrectAttempt,
      ).then((_) {
        gameState.clearAttempt();
        setState(() {
          _letterUsedStatus = List.filled(
            AppConstants.TOTAL_AVAILABLE_LETTERS,
            false,
          );
        });
        if (_currentRoundTime > 0) _startRoundTimer();
      });
      return;
    }

    if (GameLogicHelper.isValidSubmission(submittedWord, fixedLetter)) {
      gameState.addScore(AppConstants.CORRECT_REWARD);
      gameState.setGameMessage('🎉 Correct! Well done!', isCorrect: true);
      _audioService.playSfx('assets/audio/correct_answer.wav');
      _showMessageDialog(
        gameState.gameMessage,
        isCorrect: gameState.isCorrectAttempt,
      ).then((_) {
        _nextRound();
      });
    } else {
      gameState.deductScore(AppConstants.INCORRECT_PENALTY);
      gameState.setGameMessage(
        '❌ Incorrect word or not in dictionary!',
        isCorrect: false,
      );
      _audioService.playSfx('assets/audio/incorrect_answer.wav');
      _showMessageDialog(
        gameState.gameMessage,
        isCorrect: gameState.isCorrectAttempt,
      ).then((_) {
        gameState.clearAttempt();
        setState(() {
          _letterUsedStatus = List.filled(
            AppConstants.TOTAL_AVAILABLE_LETTERS,
            false,
          );
        });
        if (_currentRoundTime > 0) _startRoundTimer();
      });
    }
  }

  void _nextRound() {
    final gameState = Provider.of<GameState>(context, listen: false);
    if (gameState.round >= AppConstants.TOTAL_ROUNDS) {
      _endGame();
    } else {
      _startNewRound();
    }
  }

  void _endGame() {
    _roundTimer.cancel();
    final gameState = Provider.of<GameState>(context, listen: false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameOverScreen(
          score: gameState.score,
          roundsPlayed: gameState.round,
        ),
      ),
    );
  }

  Future<void> _showMessageDialog(
    String message, {
    required bool isCorrect,
  }) async {
    _roundTimer.cancel();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isCorrect
              ? Colors.green.shade100
              : Colors.red.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle_outline : Icons.error_outline,
                color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                size: 48,
              ),
              const SizedBox(height: 15),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCorrect
                      ? Colors.green.shade900
                      : Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _roundTimer.cancel();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF8B5CF6),
              ], // header-gradient colors
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            titleSpacing: 0,
            title: const Text(
              '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            actions: [
              Consumer<GameState>(
                builder: (context, gameState, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Score Icon and Value
                      const Icon(Icons.score, color: Colors.white, size: 30),
                      const SizedBox(width: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${gameState.score}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      const Icon(
                        Icons.looks_one,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${gameState.round}/${AppConstants.TOTAL_ROUNDS}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),
                      const Icon(Icons.timer, color: Colors.white, size: 30),
                      const SizedBox(width: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$_currentRoundTime s',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(
                              255,
                              255,
                              64,
                              64,
                            ), // Brighter red
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.help_outline,
                  size: 25,
                  color: Colors.white,
                ),
                tooltip: 'Game Instructions',
                onPressed: () {
                  _roundTimer.cancel();
                  showDialog(
                    context: context,
                    builder: (context) => const GameInstructionsDialog(),
                  ).then((_) {
                    if (mounted && _currentRoundTime > 0) {
                      _startRoundTimer();
                    }
                  });
                },
              ),
              const SizedBox(width: 6), // Padding on the right
            ],
          ),
        ),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          if (gameState.currentFixedLetter.isEmpty && gameState.round == 0 ||
              gameState.currentWordLength == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              final bool isSmallScreen = screenWidth < 640.0;

              // Responsive letter placeholder size (Form Your Word)
              final double placeholderBoxDimension = isSmallScreen
                  ? 40.0
                  : 50.0; // .letter-placeholder

              // Responsive font size for placeholder
              final double placeholderFontSize = isSmallScreen
                  ? 20.0
                  : 32.0; // text-2xl adjusted

              final double screenHorizontalPadding = 20.0;
              final double sectionVerticalSpacing = 20.0;
              final double itemSpacing = 8.0; // General spacing between items
              final double cardInternalPadding =
                  15.0; // Padding inside the white card containers

              // This will be used by LetterBox, which now dictates its own size
              // We just need to know how many columns are in the grid
              const int targetCrossAxisCount = 5;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenHorizontalPadding,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Form Your Word:',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 10),
                    // Current Attempt Display Container (White Card)
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: cardInternalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      // Height based on placeholder box size
                      height:
                          placeholderBoxDimension + (cardInternalPadding * 2),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(gameState.currentWordLength, (
                            index,
                          ) {
                            final char = index < gameState.currentAttempt.length
                                ? gameState.currentAttempt[index].toUpperCase()
                                : '?';

                            bool isFilled =
                                index < gameState.currentAttempt.length;
                            bool isFixedLetterInAttempt =
                                isFilled && index == 0;

                            return Container(
                              width:
                                  placeholderBoxDimension, // Use placeholder size
                              height:
                                  placeholderBoxDimension, // Use placeholder size
                              margin: EdgeInsets.symmetric(
                                horizontal: itemSpacing / 2,
                              ),
                              decoration: BoxDecoration(
                                color: isFilled
                                    ? Colors.white
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isFixedLetterInAttempt && isFilled
                                      ? const Color(0xFF8B5CF6)
                                      : (isFilled
                                            ? Colors.purple.shade200
                                            : Colors.grey.shade200),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.1,
                                    ), // inset box-shadow
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                    // Flutter's BoxShadow does not have an 'inset' property.
                                    // This visual is achieved by creating an inner shadow effect
                                    // via overlapping elements or by just applying a regular shadow that gives a similar feel.
                                    // For exact inset, custom painter would be needed.
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                char,
                                style: TextStyle(
                                  fontSize:
                                      placeholderFontSize, 
                                  fontWeight: FontWeight.bold,
                                  color: isFixedLetterInAttempt && isFilled
                                      ? const Color(0xFF8B5CF6)
                                      : (isFilled
                                            ? Colors.black87
                                            : Colors.grey.shade400),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child:
                                // Remove Last Button
                                ElevatedButton.icon(
                                  onPressed: _removeLastLetter,
                                  icon: const Icon(Icons.close, size: 20),
                                  label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('Remove Last'),
                                  ),
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 12,
                                      ),
                                    ),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    textStyle: MaterialStateProperty.all(
                                      const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    overlayColor:
                                        MaterialStateProperty.resolveWith<
                                          Color?
                                        >((Set<MaterialState> states) {
                                          if (states.contains(
                                            MaterialState.hovered,
                                          )) {
                                            return const Color(0xFFE67E22);
                                          }
                                          return null;
                                        }),
                                    shadowColor: MaterialStateProperty.all(
                                      const Color(0x4DC87E00),
                                    ),
                                    elevation: MaterialStateProperty.all(4),
                                    backgroundColor: MaterialStateProperty.all(
                                      const Color(0xFFF59E0B),
                                    ),
                                    foregroundColor: MaterialStateProperty.all(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child:
                                // Submit Word Button
                                ElevatedButton.icon(
                                  onPressed:
                                      gameState.currentAttempt.length ==
                                          gameState.currentWordLength
                                      ? _submitWord
                                      : null,
                                  icon: const Icon(Icons.check, size: 20),
                                  label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('Submit Word'),
                                  ),
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 12,
                                      ),
                                    ),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    textStyle: MaterialStateProperty.all(
                                      const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    overlayColor:
                                        MaterialStateProperty.resolveWith<
                                          Color?
                                        >((Set<MaterialState> states) {
                                          if (states.contains(
                                            MaterialState.hovered,
                                          )) {
                                            return const Color(0xFF6D28D9);
                                          }
                                          return null;
                                        }),
                                    shadowColor: MaterialStateProperty.all(
                                      const Color(0x4D8B5CF6),
                                    ),
                                    elevation:
                                        MaterialStateProperty.resolveWith<
                                          double?
                                        >((Set<MaterialState> states) {
                                          if (states.contains(
                                            MaterialState.disabled,
                                          )) {
                                            return 0;
                                          }
                                          return 4;
                                        }),
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith<
                                          Color?
                                        >((Set<MaterialState> states) {
                                          if (states.contains(
                                            MaterialState.disabled,
                                          )) {
                                            return const Color(0xFFE5E7EB);
                                          }
                                          return const Color(0xFF8B5CF6);
                                        }),
                                    foregroundColor:
                                        MaterialStateProperty.resolveWith<
                                          Color?
                                        >((Set<MaterialState> states) {
                                          if (states.contains(
                                            MaterialState.disabled,
                                          )) {
                                            return const Color(0xFF9CA3AF);
                                          }
                                          return Colors.white;
                                        }),
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sectionVerticalSpacing),
                    const Text(
                      'Available Letters:',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 10),
                    // Available Letters Grid Container (White Card)
                    Container(
                      padding: EdgeInsets.all(cardInternalPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: targetCrossAxisCount,
                          childAspectRatio: 1.0, // Ensures square boxes
                          crossAxisSpacing: itemSpacing,
                          mainAxisSpacing: itemSpacing,
                        ),
                        itemCount: AppConstants.TOTAL_AVAILABLE_LETTERS,
                        itemBuilder: (context, index) {
                          final letter =
                              index < gameState.currentAvailableLetters.length
                              ? gameState.currentAvailableLetters[index]
                              : '';

                          Color boxBackgroundColor;
                          Color boxBorderColor;
                          Color boxTextColor;
                          bool isFixed =
                              index == 0; // Check if it's the fixed letter

                          if (isFixed) {
                            boxBackgroundColor = const Color(
                              0xFFFACC15,
                            ); // bg-yellow-400
                            boxBorderColor = const Color(0xFFF59E0B);
                            boxTextColor = const Color(0xFFB45309);
                          } else {
                            boxBackgroundColor = const Color(
                              0xFFBFDBFE,
                            ); // bg-blue-300
                            boxBorderColor = const Color(0xFF60A5FA);
                            boxTextColor = const Color(0xFF1D4ED8);
                          }

                          return LetterBox(
                            letter: letter,
                            onTap: () => _onLetterTap(letter, index),
                            isUsed: _letterUsedStatus[index],
                            letterSize:
                                0, // No longer used for box size, but for font size (passed internally)
                            backgroundColor: boxBackgroundColor,
                            borderColor: boxBorderColor,
                            textColor: boxTextColor,
                            isFixedLetter: isFixed,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
