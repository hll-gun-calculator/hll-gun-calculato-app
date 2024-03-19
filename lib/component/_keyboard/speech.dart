import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../data/index.dart';
import 'theme.dart';

class SpeechKeyboard extends StatefulWidget {
  final ValueNotifier<TextEditingController> controller;
  final Function onSubmit;
  late KeyboardTheme theme;
  final Factions? inputFactions;

  SpeechKeyboard({
    super.key,
    KeyboardTheme? theme,
    required this.onSubmit,
    required this.controller,
    this.inputFactions,
  }) : super() {
    this.theme = theme ?? KeyboardTheme();
  }

  @override
  State<SpeechKeyboard> createState() => _SpeechKeyboardState();
}

class _SpeechKeyboardState extends State<SpeechKeyboard> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  bool _isSpeechNumber(String content) {
    dynamic canNumber = num.tryParse(content);
    return content.isNotEmpty && canNumber != null && canNumber != double.infinity && !canNumber.isNaN;
  }

  void _sum() {
    if (_isSpeechNumber(_lastWords)) {
      widget.controller.value.text = num.parse(_lastWords).toString();
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!_speechToText.isNotListening) Icon(Icons.settings_voice_rounded),
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 20),
              child: Text(
                _speechToText.isListening
                    ? _lastWords
                    : _speechEnabled
                        ? '点击麦克风开始收听…'
                        : '设备不支持',
              ),
            ),
            GestureDetector(
              onLongPressStart: (d) {
                _startListening();
              },
              onLongPressUp: _speechEnabled == false
                  ? null
                  : () {
                      _stopListening();
                      _sum();
                    },
              child: ElevatedButton(
                onPressed: _speechEnabled == false ? null : () => {},
                child: Icon(Icons.mic, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
