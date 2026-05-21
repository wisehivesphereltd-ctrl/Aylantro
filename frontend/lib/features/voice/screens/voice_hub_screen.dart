import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../providers/translation_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class VoiceHubScreen extends StatefulWidget {
  const VoiceHubScreen({super.key});

  @override
  State<VoiceHubScreen> createState() => _VoiceHubScreenState();
}

class _VoiceHubScreenState extends State<VoiceHubScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcribedText = '';
  final double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<TranslationProvider>(context, listen: false).clear();
      }
    });
  }

  Future<void> _listen(TranslationProvider provider) async {
    if (!_isListening) {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required')),
          );
        }
        return;
      }

      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
            if (_transcribedText.isNotEmpty && !provider.isTranslating) {
              provider.setSourceText(_transcribedText);
              provider.translate();
            }
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _transcribedText = '';
        });
        _speech.listen(
          localeId: provider.sourceLanguage, // LISTEN IN THE SELECTED LANGUAGE
          onResult: (val) {
            setState(() {
              _transcribedText = val.recognizedWords;
            });
            if (val.finalResult && _transcribedText.isNotEmpty && !provider.isTranslating) {
              provider.setSourceText(_transcribedText);
              provider.translate();
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_transcribedText.isNotEmpty && !provider.isTranslating) {
        provider.setSourceText(_transcribedText);
        provider.translate();
      }
    }
  }

  void _showLanguagePicker(
    BuildContext context,
    TranslationProvider provider,
    bool isSource,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select ${isSource ? 'Source' : 'Target'} Language',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...AppConstants.availableLanguages.entries.map((entry) {
                return ListTile(
                  title: Text(
                    entry.value,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  onTap: () {
                    if (isSource) {
                      provider.setSourceLanguage(entry.key);
                    } else {
                      provider.setTargetLanguage(entry.key);
                    }
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Voice Hub'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            provider.clear();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          _buildLanguageIndicator(provider),
          const Spacer(),
          _buildTranscriptionArea(provider),
          const Spacer(),
          _buildMicButton(provider),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildLanguageIndicator(TranslationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.4), width: 1.5),
        boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _showLanguagePicker(context, provider, true),
            child: Text(
              AppConstants.getLanguageName(provider.sourceLanguage).toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.secondaryColor),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.arrow_forward_rounded, size: 20, color: AppTheme.secondaryColor),
          ),
          GestureDetector(
            onTap: () => _showLanguagePicker(context, provider, false),
            child: Text(
              AppConstants.getLanguageName(provider.targetLanguage).toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionArea(TranslationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white54 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Source Card (English)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.5), width: 1.5),
              boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        AppConstants.getLanguageName(provider.sourceLanguage).toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, letterSpacing: 1.2),
                      ),
                    ),
                    Icon(Icons.mic_none_rounded, color: labelColor, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _isListening
                      ? (_transcribedText.isEmpty ? 'Listening...' : _transcribedText)
                      : (_transcribedText.isEmpty ? 'Tap the mic to speak' : _transcribedText),
                  style: TextStyle(
                    fontSize: 22,
                    color: _isListening ? AppTheme.secondaryColor : textColor,
                    height: 1.5,
                    fontWeight: _transcribedText.isEmpty ? FontWeight.w400 : FontWeight.w600,
                    fontStyle: _transcribedText.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Target Card (Translation)
          if (provider.translatedText.isNotEmpty || provider.isTranslating)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.6), width: 1.5),
                boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          AppConstants.getLanguageName(provider.targetLanguage).toUpperCase(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, letterSpacing: 1.2),
                        ),
                      ),
                      const Icon(Icons.auto_awesome_rounded, size: 20, color: AppTheme.secondaryColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.isTranslating ? 'Translating...' : provider.translatedText,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: provider.isTranslating ? labelColor : textColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!provider.isTranslating && provider.translatedText.isNotEmpty)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => provider.speak(provider.translatedText, provider.targetLanguage),
                        icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 22),
                        label: const Text('SPEAK RESULT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          elevation: 6,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMicButton(TranslationProvider provider) {
    return GestureDetector(
      onTap: () => _listen(provider),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isListening ? AppTheme.accentColor : AppTheme.primaryColor,
          boxShadow: [
            BoxShadow(
              color: (_isListening ? AppTheme.accentColor : AppTheme.primaryColor).withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: _isListening ? 10 : 0,
            ),
          ],
        ),
        child: const Icon(
          Icons.mic_rounded,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}
