import 'package:metronome/metronome.dart';

class MetronomService {

  final Metronome _metronomePlugin = Metronome();

  void init() {
    _metronomePlugin.init(
      'assets/metro-sound.wav',
      bpm: 120,
      volume: 100,
      enableTickCallback: true,
    );
  }

  void play(int bpm) {
    _metronomePlugin.setBPM(bpm);
    _metronomePlugin.play();
  }

  void stop() {
    _metronomePlugin.stop();
  }

  void pause() {
    _metronomePlugin.pause();
  }

  void setBpm(int bpm) {
    _metronomePlugin.setBPM(bpm);
  }
}
