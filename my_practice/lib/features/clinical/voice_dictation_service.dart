import 'package:speech_to_text/speech_to_text.dart';

class VoiceDictationService {
  VoiceDictationService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;

  Future<void> listen(void Function(String text) onResult) async {
    final available = await _speech.initialize();
    if (!available) return;

    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
      listenMode: ListenMode.dictation,
    );
  }

  Future<void> stop() => _speech.stop();
}
