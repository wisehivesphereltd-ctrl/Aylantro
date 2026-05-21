import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/translation_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class TextTranslationScreen extends StatefulWidget {
  final bool autofocus;
  const TextTranslationScreen({super.key, this.autofocus = true});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final trans = Provider.of<TranslationProvider>(context, listen: false);
    _sourceController.text = trans.sourceText;
    _targetController.text = trans.translatedText;
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_sourceController.text != provider.sourceText) {
      _sourceController.text = provider.sourceText;
    }
    if (_targetController.text != provider.translatedText) {
      _targetController.text = provider.translatedText;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.primaryColor.withOpacity(0.4) : AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildLanguageSelector(context, provider),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded, color: Colors.white),
            onPressed: () {
              provider.clear();
              _sourceController.clear();
              _targetController.clear();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTranslationBox(
                context,
                title: provider.sourceLanguage,
                hint: 'Type or paste text to translate...',
                controller: _sourceController,
                isSource: true,
                provider: provider,
                autofocus: widget.autofocus,
              ),
              const SizedBox(height: 16),
              _buildTranslationBox(
                context,
                title: provider.targetLanguage,
                hint: provider.isTranslating ? 'Translating...' : 'Translation will appear here',
                controller: _targetController,
                isSource: false,
                provider: provider,
                autofocus: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, TranslationProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppConstants.getLanguageName(provider.sourceLanguage),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), // White on Red
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.swap_horiz_rounded, color: AppTheme.accentColor, size: 20),
          ),
          Text(
            AppConstants.getLanguageName(provider.targetLanguage),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), // White on Red
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationBox(
    BuildContext context, {
    required String title,
    required String hint,
    required TextEditingController controller,
    required bool isSource,
    required TranslationProvider provider,
    required bool autofocus,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark 
                  ? (isSource ? AppTheme.primaryColor.withOpacity(0.15) : AppTheme.secondaryColor.withOpacity(0.08))
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSource ? AppTheme.primaryColor.withOpacity(isDark ? 0.5 : 0.6) : AppTheme.secondaryColor.withOpacity(isDark ? 0.4 : 0.6),
                width: 1.5,
              ),
              boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSource ? AppTheme.primaryColor : AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppConstants.getLanguageName(title).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.copy_rounded, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                          onPressed: () {
                            final text = isSource ? provider.sourceText : provider.translatedText;
                            if (text.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.volume_up_rounded, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                          onPressed: () {
                            final text = isSource ? provider.sourceText : provider.translatedText;
                            final lang = isSource ? provider.sourceLanguage : provider.targetLanguage;
                            if (text.isNotEmpty) provider.speak(text, lang);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus: autofocus,
                    maxLines: null,
                    expands: true,
                    readOnly: !isSource,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: isSource ? (val) => provider.setSourceText(val) : null,
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.5,
                      color: isSource ? (isDark ? Colors.white : Colors.black87) : (isDark ? AppTheme.secondaryColor : AppTheme.primaryColor),
                      fontWeight: isSource ? FontWeight.normal : FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
