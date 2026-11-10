import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Background music with user-controlled playback.
/// Nothing plays until [startAfterInteraction] / [toggle] is called from a tap,
/// which satisfies browser autoplay rules (including WhatsApp / iOS in-app browsers).
class MusicService extends ChangeNotifier with WidgetsBindingObserver {
  MusicService._() {
    WidgetsBinding.instance.addObserver(this);
  }
  static final MusicService instance = MusicService._();

  AudioPlayer? _player;
  bool _configured = false;
  bool _playing = false;
  bool _failed = false;
  bool _userPaused = false;
  bool _resumeOnReturn = false;

  bool get isPlaying => _playing;
  bool get hasFailed => _failed;

  /// Called when the guest opens the envelope.
  Future<void> startAfterInteraction() async {
    if (_userPaused || _playing) return;
    await _play();
  }

  /// Called by the ON/OFF button.
  Future<void> toggle() async {
    if (_playing) {
      _userPaused = true;
      await _pause();
    } else {
      _userPaused = false;
      await _play();
    }
  }

  Future<void> _play() async {
    if (_failed) return;
    try {
      final player = _player ??= AudioPlayer();
      if (!_configured) {
        await player.setReleaseMode(ReleaseMode.loop);
        await player.setVolume(0.55);
        _configured = true;
      }
      if (player.state == PlayerState.paused) {
        await player.resume();
      } else {
        await player.play(AssetSource('audio/music.mp3'));
      }
      _playing = true;
    } catch (e) {
      debugPrint('Music unavailable: $e');
      _failed = true;
      _playing = false;
    }
    notifyListeners();
  }

  Future<void> _pause() async {
    try {
      await _player?.pause();
    } catch (e) {
      debugPrint('Music pause failed: $e');
    }
    _playing = false;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_resumeOnReturn) {
          _resumeOnReturn = false;
          _play();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (_playing) {
          _resumeOnReturn = true;
          _pause();
        }
        break;
      default:
        break;
    }
  }
}
