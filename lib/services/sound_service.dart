import 'sound_service_stub.dart'
    if (dart.library.js_interop) 'sound_service_web.dart';

abstract class SoundService {
  static final SoundService instance = getSoundServiceImpl();

  void playSound(String type);
  void playAmbient(String soundType, double volume);
  void stopAmbient();
}
