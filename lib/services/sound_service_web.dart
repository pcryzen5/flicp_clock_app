import 'dart:js_interop';
import 'package:flutter/services.dart';
import 'sound_service.dart';

@JS('playPomodoroSound')
external void _playPomodoroSound(JSString type);

@JS('playAmbientSound')
external void _playAmbientSound(JSString soundType, JSNumber volume);

@JS('stopAmbientSound')
external void _stopAmbientSound();

SoundService getSoundServiceImpl() => SoundServiceWeb();

class SoundServiceWeb implements SoundService {
  @override
  void playSound(String type) {
    try {
      _playPomodoroSound(type.toJS);
    } catch (_) {
      SystemSound.play(type == 'finish' ? SystemSoundType.alert : SystemSoundType.click);
    }
  }

  @override
  void playAmbient(String soundType, double volume) {
    try {
      _playAmbientSound(soundType.toJS, volume.toJS);
    } catch (_) {}
  }

  @override
  void stopAmbient() {
    try {
      _stopAmbientSound();
    } catch (_) {}
  }
}
