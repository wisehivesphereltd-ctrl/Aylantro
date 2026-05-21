import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../providers/translation_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class SplitConversationScreen extends StatefulWidget {
  const SplitConversationScreen({super.key});

  @override
  State<SplitConversationScreen> createState() => _SplitConversationScreenState();
}

class _SplitConversationScreenState extends State<SplitConversationScreen> {
  late stt.SpeechToText _speech;
  bool _isListeningTop = false;
  bool _isListeningBottom = false;

  String _topText = 'Tap mic to speak (Person 1)';
  String _bottomText = 'Tap mic to speak (Person 2)';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen(bool isTop, TranslationProvider provider) async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required for conversation')),
        );
      }
      return;
    }

    if (isTop ? _isListeningTop : _isListeningBottom) {
      setState(() {
        if (isTop) _isListeningTop = false;
        else _isListeningBottom = false;
      });
      _speech.stop();
      return;
    }

    // Stop the other side if listening
    if (_isListeningTop || _isListeningBottom) {
      _speech.stop();
      setState(() {
        _isListeningTop = false;
        _isListeningBottom = false;
      });
    }

    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          if (mounted) {
            setState(() {
              _isListeningTop = false;
              _isListeningBottom = false;
            });
          }
        }
      },
    );

    if (available && mounted) {
      setState(() {
        if (isTop) {
          _isListeningTop = true;
          _topText = 'Listening...';
        } else {
          _isListeningBottom = true;
          _bottomText = 'Listening...';
        }
      });

      final listenLang = isTop ? provider.sourceLanguage : provider.targetLanguage;
      final targetLang = isTop ? provider.targetLanguage : provider.sourceLanguage;

      _speech.listen(
        localeId: listenLang,
        onResult: (val) async {
          if (mounted) {
            setState(() {
              if (isTop) _topText = val.recognizedWords;
              else _bottomText = val.recognizedWords;
            });
          }

          if (val.finalResult && val.recognizedWords.isNotEmpty) {
            // Process translation
            provider.setSourceLanguage(listenLang);
            provider.setTargetLanguage(targetLang);
            provider.setSourceText(val.recognizedWords);
            await provider.translate();

            if (mounted) {
              setState(() {
                if (isTop) {
                  _bottomText = provider.translatedText;
                } else {
                  _topText = provider.translatedText;
                }
              });
              provider.speak(provider.translatedText, targetLang);
            }
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Top Half (Rotated 180 Degrees for Person 1 sitting across)
          Expanded(
            child: RotatedBox(
              quarterTurns: 2,
              child: _buildHalfCard(
                context: context,
                title: AppConstants.getLanguageName(provider.sourceLanguage),
                text: _topText,
                isListening: _isListeningTop,
                onMicTap: () => _listen(true, provider),
                onLangTap: () => _showLanguagePicker(context, provider, true),
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          // Divider bar with close button
          Container(
            height: 54,
            color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
            decoration: isDark ? null : const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black12),
                bottom: BorderSide(color: Colors.black12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.swap_vert_rounded, color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor),
                  onPressed: () => provider.swapLanguages(),
                ),
                TextButton.icon(
                  icon: Icon(Icons.close_fullscreen_rounded, color: isDark ? Colors.white70 : AppTheme.primaryColor),
                  label: Text('EXIT SPLIT SCREEN', style: TextStyle(color: isDark ? Colors.white70 : AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up_rounded, color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor),
                  onPressed: () {
                    provider.speak(_bottomText, provider.targetLanguage);
                  },
                ),
              ],
            ),
          ),
          // Bottom Half (Standard Orientation for Person 2)
          Expanded(
            child: _buildHalfCard(
              context: context,
              title: AppConstants.getLanguageName(provider.targetLanguage),
              text: _bottomText,
              isListening: _isListeningBottom,
              onMicTap: () => _listen(false, provider),
              onLangTap: () => _showLanguagePicker(context, provider, false),
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalfCard({
    required BuildContext context,
    required String title,
    required String text,
    required bool isListening,
    required VoidCallback onMicTap,
    required VoidCallback onLangTap,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? color.withOpacity(0.12) : color.withOpacity(0.06);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardBgColor,
        border: Border.all(color: color.withOpacity(isDark ? 0.3 : 0.4), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onLangTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)), // White on Red card
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
              if (isListening)
                const Row(
                  children: [
                    Icon(Icons.mic, color: Colors.redAccent, size: 18),
                    SizedBox(width: 6),
                    Text('LISTENING...', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
            ],
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: text.length > 50 ? 22 : 28,
                    fontWeight: FontWeight.w600,
                    color: isListening 
                        ? AppTheme.secondaryColor 
                        : (isDark ? Colors.white : AppTheme.primaryColor),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onMicTap,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isListening ? Colors.redAccent : color,
                boxShadow: [
                  BoxShadow(color: (isListening ? Colors.redAccent : color).withOpacity(0.5), blurRadius: 28),
                ],
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 38),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, TranslationProvider provider, bool isSource) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select ${isSource ? 'Person 1' : 'Person 2'} Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryColor)),
              const SizedBox(height: 20),
              ...AppConstants.availableLanguages.entries.map((entry) {
                return ListTile(
                  title: Text(entry.value, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                  onTap: () {
                    if (isSource) provider.setSourceLanguage(entry.key);
                    else provider.setTargetLanguage(entry.key);
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
}
