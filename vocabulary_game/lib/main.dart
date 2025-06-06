import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabulary_game/screens/home_screen.dart';
import 'package:vocabulary_game/models/game_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
        // Add other providers if needed, e.g., for dictionary loading status
      ],
      child: MaterialApp(
        title: 'Word Scramble',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: const HomeScreen(),
        // Add this line to remove the debug banner
        debugShowCheckedModeBanner: false, // <-- HERE IT IS!
      ),
    );
  }
}