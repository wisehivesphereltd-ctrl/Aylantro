import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../providers/translation_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class PronunciationCoachScreen extends StatefulWidget {
  final String targetPhrase;
  final String targetLang;
  const PronunciationCoachScreen({super.key, required this.targetPhrase, required this.targetLang});

  @override
  State<PronunciationCoachScreen> createState() => _PronunciationCoachScreenState();
}

class _PronunciationCoachScreenState extends State<PronunciationCoachScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = '';
  int? _accuracyScore;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission required for Coach')));
      }
      return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
            if (_spokenText.isNotEmpty) {
              _calculateScore();
            }
          }
        },
      );

      if (available && mounted) {
        setState(() {
          _isListening = true;
          _spokenText = '';
          _accuracyScore = null;
        });

        _speech.listen(
          localeId: widget.targetLang,
          onResult: (val) {
            if (mounted) {
              setState(() {
                _spokenText = val.recognizedWords;
              });
            }
            if (val.finalResult && val.recognizedWords.isNotEmpty) {
              _calculateScore();
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_spokenText.isNotEmpty) {
        _calculateScore();
      }
    }
  }

  void _calculateScore() {
    setState(() => _isAnalyzing = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      final targetClean = widget.targetPhrase.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
      final spokenClean = _spokenText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();

      if (spokenClean.isEmpty) {
        setState(() {
          _accuracyScore = 0;
          _isAnalyzing = false;
        });
        return;
      }

      final targetWords = targetClean.split(' ');
      final spokenWords = spokenClean.split(' ');

      int matches = 0;
      for (final w in spokenWords) {
        if (targetWords.contains(w)) matches++;
      }

      double ratio = matches / max(targetWords.length, spokenWords.length);
      int score = ((ratio * 60) + (spokenClean.length > 2 ? 40 : 10)).round().clamp(10, 100);

      setState(() {
        _accuracyScore = score;
        _isAnalyzing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Pronunciation Coach', style: TextStyle(color: isDark ? Colors.white : AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppTheme.primaryColor), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Target Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(isDark ? 0.5 : 0.6), width: 1.5),
                  boxShadow: isDark ? [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.2), blurRadius: 24),
                  ] : [
                    const BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.secondaryColor)),
                      child: Text(AppConstants.getLanguageName(widget.targetLang).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.targetPhrase,
                      style: TextStyle(fontSize: 26, color: isDark ? Colors.white : AppTheme.primaryColor, fontWeight: FontWeight.bold, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => provider.speak(widget.targetPhrase, widget.targetLang),
                      icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                      label: const Text('LISTEN NATIVE AUDIO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Practice Feedback Area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.5), width: 1.5),
                    boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 6))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isAnalyzing)
                        Column(
                          children: [
                            const CircularProgressIndicator(color: AppTheme.accentColor),
                            const SizedBox(height: 16),
                            Text('Analyzing acoustic waveforms...', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
                          ],
                        )
                      else if (_accuracyScore != null)
                        Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _accuracyScore! >= 80 ? AppTheme.accentColor : (_accuracyScore! >= 50 ? Colors.orangeAccent : Colors.redAccent),
                                boxShadow: [
                                  BoxShadow(color: (_accuracyScore! >= 80 ? AppTheme.accentColor : Colors.orangeAccent).withOpacity(0.5), blurRadius: 28),
                                ],
                              ),
                              child: Center(
                                child: Text('$_accuracyScore%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _accuracyScore! >= 90 ? 'Perfect Pronunciation! 🏆' : (_accuracyScore! >= 75 ? 'Excellent Work! 🌟' : (_accuracyScore! >= 50 ? 'Good Effort, Try Again!' : 'Needs Practice')),
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _spokenText.isEmpty ? 'Nothing recorded' : 'You said: "$_spokenText"',
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16, fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Icon(Icons.mic_none_rounded, size: 72, color: isDark ? Colors.white24 : Colors.black26),
                            const SizedBox(height: 16),
                            Text('Tap the microphone below and repeat the phrase', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 16), textAlign: TextAlign.center),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Mic Button
              Center(
                child: GestureDetector(
                  onTap: _listen,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.redAccent : AppTheme.primaryColor,
                      boxShadow: [
                        BoxShadow(color: (_isListening ? Colors.redAccent : AppTheme.primaryColor).withOpacity(0.5), blurRadius: 36),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.mic_rounded, size: 44, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
