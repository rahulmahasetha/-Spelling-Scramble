import 'package:flutter/material.dart';

class GameInstructionsDialog extends StatelessWidget {
  const GameInstructionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'How to Play Spelling Scramble',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Objective:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              'Form valid 3, 4 and 5 letter English words using the available letters.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Text(
              'Rules:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              '1. Start with the Fixed Letter: Every word must begin with the fixed letter (highlighted in orange).',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 5),
            const Text(
              '2. Use Available Letters: After the fixed letter, use only the available letters to form the rest of the word.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 5),
            const Text(
              '3. No Repetition: Each letter can be used only once at a given available letters.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Text(
              'Scoring:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              '•  Correct word: +10 points.',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '•  Incorrect word: 1 point will be deducted.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Text(
              'Time Limit:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              'Each round has a 90-second time limit. If time runs out, 1 point will be deducted for that round.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Text(
              'Rounds:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              '•  1st to 3rd round: You get 3 letter boxes.\n'
              '•  4th to 7th round: You get 4 letter boxes.\n'
              '•  8th to 10th round: You get 5 letter boxes.\n\n'
              'The game consists of 10 rounds. Try to get the highest score!',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Text(
              'Actions:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              '•  Tap letters to add them to your word.',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '•  "Remove Last" button: Deletes the last letter you added.',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '•  "Submit Word" button: Checks your word. Only enabled when your word matches the required length.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Got It!', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
