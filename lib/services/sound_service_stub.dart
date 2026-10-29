import 'package:flutter/services.dart';
import 'sound_service.dart';

SoundService getSoundServiceImpl() => SoundServiceStub();

class SoundServiceStub implements SoundService {
  @override
  void playSound(String type) {
    if (type == 'finish') {
      SystemSound.play(SystemSoundType.alert);
    } else {
      SystemSound.play(SystemSoundType.click);
    }
  }

  @override
  void playAmbient(String soundType, double volume) {
    // Ambient procedural audio synthesis is supported on Web.
  }

  @override
  void stopAmbient() {
    // No-op on native platforms
  }
}
