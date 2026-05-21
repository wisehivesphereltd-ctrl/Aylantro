import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/translation_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AiContextModal extends StatefulWidget {
  final String initialPhrase;
  const AiContextModal({super.key, required this.initialPhrase});

  @override
  State<AiContextModal> createState() => _AiContextModalState();
}

class _AiContextModalState extends State<AiContextModal> {
  late TextEditingController _controller;
  Map<String, dynamic>? _analysis;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPhrase);
    if (widget.initialPhrase.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runAnalysis();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    final phrase = _controller.text.trim();
    if (phrase.isEmpty) return;

    setState(() {
      _isLoading = true;
      _analysis = null;
    });

    final provider = Provider.of<TranslationProvider>(context, listen: false);
    final result = await provider.translateWithAiContext(phrase, provider.sourceLanguage, provider.targetLanguage);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _analysis = result;
      });

      if (result['status'] == 'QUOTA_REACHED') {
        _showQuotaPopup(provider);
      }
    }
  }

  void _showQuotaPopup(TranslationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: AppTheme.accentColor, width: 2)),
        title: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded, color: AppTheme.accentColor, size: 32),
            const SizedBox(width: 12),
            Text('Daily Limit Reached', style: TextStyle(color: isDark ? Colors.white : AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: Text(
          'You have used all 3 free Premium AI Context / OCR translations for today. Watch a quick 15s sponsored ad to unlock another translation immediately!',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('NO THANKS', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await provider.unlockWithRewardedAd();
              _runAnalysis();
            },
            icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white),
            label: const Text('WATCH AD TO UNLOCK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Cultural AI Context', style: TextStyle(color: isDark ? Colors.white : AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : AppTheme.primaryColor), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Phrase Input Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.secondaryColor.withOpacity(isDark ? 0.5 : 0.6), width: 1.5),
                  boxShadow: isDark ? [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.2), blurRadius: 20),
                  ] : [
                    const BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppConstants.getLanguageName(provider.sourceLanguage)} ➔ ${AppConstants.getLanguageName(provider.targetLanguage)}',
                          style: TextStyle(color: isDark ? AppTheme.accentColor : AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Icon(Icons.psychology_rounded, color: isDark ? AppTheme.accentColor : AppTheme.primaryColor, size: 22),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      style: TextStyle(fontSize: 20, color: isDark ? Colors.white : AppTheme.primaryColor, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Enter idiom or slang phrase...',
                        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _runAnalysis(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _runAnalysis,
                        icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.auto_awesome, color: Colors.white),
                        label: Text(_isLoading ? 'ANALYZING CULTURE...' : 'ANALYZE IDIOM & TONE', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Results Section
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: AppTheme.accentColor),
                            const SizedBox(height: 20),
                            Text('Decoding cultural nuances & regional tone...', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
                          ],
                        ),
                      )
                    : _analysis == null || _analysis!['status'] == 'QUOTA_REACHED'
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lightbulb_outline_rounded, size: 80, color: isDark ? Colors.white24 : Colors.black26),
                            const SizedBox(height: 16),
                            Text('Type slang or regional phrase to uncover deeper meaning', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 16), textAlign: TextAlign.center),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildResultCard(context, 'Literal Translation', _analysis!['literal'], Icons.translate_rounded, AppTheme.secondaryColor),
                            _buildResultCard(context, 'Cultural Nuance & Idiom Meaning', _analysis!['cultural'], Icons.menu_book_rounded, AppTheme.accentColor),
                            _buildResultCard(context, 'Polite / Professional Form', _analysis!['polite'], Icons.work_outline_rounded, Colors.blueAccent),
                            _buildResultCard(context, 'Communicative Tone', _analysis!['tone'], Icons.record_voice_over_rounded, Colors.green),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, String title, String content, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(isDark ? 0.4 : 0.6), width: 1.5),
        boxShadow: isDark ? [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 16),
        ] : [
          const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(title.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: TextStyle(fontSize: 18, color: isDark ? Colors.white : AppTheme.primaryColor, height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
