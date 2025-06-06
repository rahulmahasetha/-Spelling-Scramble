import 'package:just_audio/just_audio.dart';

class AudioService {

  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
 
  bool _isBackgroundMusicPlaying = false;


  Future<void> init() async {
  
  }

 
  Future<void> playBackgroundMusic(String audioPath) async {
    if (_isBackgroundMusicPlaying) {
      await _backgroundPlayer
          .stop(); 
    }
    // Set to loop indefinitely
    await _backgroundPlayer.setLoopMode(
      LoopMode.one,
    ); // Use LoopMode.one for just_audio
    await _backgroundPlayer.setVolume(
      0.3,
    ); // Adjust volume for background music
    try {
      // Use AudioSource.asset for just_audio to load from assets
      await _backgroundPlayer.setAsset(audioPath);
      await _backgroundPlayer.play();
      _isBackgroundMusicPlaying = true;
    } catch (e) {
      print("Error loading background music: $e"); // Debugging
      _isBackgroundMusicPlaying = false;
    }
  }

  /// Stops the background music.
  Future<void> stopBackgroundMusic() async {
    await _backgroundPlayer.stop();
    _isBackgroundMusicPlaying = false;
  }

 
  Future<void> playSfx(String audioPath, {double volume = 1.0}) async {
    final player = AudioPlayer(); // Create a new player for each SFX
    try {
      await player.setVolume(volume);
      // Use AudioSource.asset for just_audio
      await player.setAsset(audioPath);
      await player.play();
      // Listen for completion and dispose the player to free resources
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.dispose();
        }
      });
    } catch (e) {
      print("Error playing sound effect: $e"); // Debugging
      player.dispose(); // Ensure dispose even on error
    }
  }

 
  void dispose() {
    _backgroundPlayer.dispose();
   
  }
}
