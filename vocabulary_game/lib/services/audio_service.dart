import 'package:just_audio/just_audio.dart';
//import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';
//import 'package:just_audio/just_audio.dart';

class AudioService {
  // Singleton pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  // _sfxPlayer is not explicitly used in your current playSfx, but kept if you intend to reuse it later.
  // If you always create new players for SFX, you could remove this line.
  // final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isBackgroundMusicPlaying = false;

  // Initialize method to prepare audio players.
  // You might want to set up audio sessions here for iOS/Android.
  Future<void> init() async {
    // Example: configure audio session for playback
    // await _backgroundPlayer.setAudioSession(AudioSession(
    //   contentType: AudioSessionContentType.music,
    //   usage: AudioSessionUsage.media,
    //   // ... other options
    // ));
  }

  /// Plays background music from the specified asset path.
  /// Stops any currently playing background music first.
  Future<void> playBackgroundMusic(String audioPath) async {
    if (_isBackgroundMusicPlaying) {
      await _backgroundPlayer
          .stop(); // Stop current music before playing new one
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

  /// Plays a short sound effect from the specified asset path.
  /// A new AudioPlayer instance is created for each SFX to allow overlapping sounds,
  /// and then disposed of automatically after playing.
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

  /// Disposes of all internal audio players to release resources.
  /// Call this when your app is shutting down or the audio service is no longer needed.
  void dispose() {
    _backgroundPlayer.dispose();
    // If you ever used _sfxPlayer for single, non-overlapping SFX, dispose it here too.
    // _sfxPlayer.dispose();
  }
}
