import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/translation_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../vision/screens/vision_lens_screen.dart';
import '../../voice/screens/voice_hub_screen.dart';
import '../../docs/screens/doc_trans_screen.dart';
import '../../voice/screens/split_conversation_screen.dart';
import '../../voice/screens/pronunciation_coach_screen.dart';
import 'ai_context_modal.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'text_translation_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sync AuthProvider user premium status to TranslationProvider
    if (authProvider.isLoggedIn && authProvider.user != null) {
      final isUserPremium = (authProvider.user!['isPremium'] == 1 || authProvider.user!['isPremium'] == true);
      if (translationProvider.isPremium != isUserPremium) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          translationProvider.setPremium(isUserPremium);
        });
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppTheme.secondaryColor, size: 26),
            const SizedBox(width: 10),
            Text('Aylantro AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: isDark ? Colors.white : AppTheme.primaryColor, letterSpacing: 0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: isDark ? Colors.white : AppTheme.primaryColor),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          IconButton(
            icon: Icon(Icons.settings_rounded, color: isDark ? Colors.white : AppTheme.primaryColor),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Premium Gradient Background (Dynamic for Day/Night)
          if (isDark)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3A0007), Color(0xFF110002), Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            )
          else ...[
            Container(color: Colors.white),
            // Faint, glowing decorative aesthetic elements for a premium light feel
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentColor.withOpacity(0.03),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.85),
                    const Color(0xFFF9FAFC),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLanguageSelector(context, translationProvider),
                  const SizedBox(height: 24),
                  
                  // Hero Tap-to-Translate Card
                  _buildHeroTextStudioCard(context, translationProvider),
                  
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      'AI TRANSLATION SUITES',
                      style: TextStyle(color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Premium Action Grid
                  Expanded(
                    child: _buildPremiumActionGrid(context, translationProvider),
                  ),
                  
                  _buildAdBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, TranslationProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor, // Red background
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showLanguagePicker(context, provider, true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  AppConstants.getLanguageName(provider.sourceLanguage),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white), // White on Red
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: const Icon(Icons.swap_horizontal_circle_rounded, color: AppTheme.accentColor, size: 36),
              onPressed: () => provider.swapLanguages(),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showLanguagePicker(context, provider, false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  AppConstants.getLanguageName(provider.targetLanguage),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white), // White on Red
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTextStudioCard(BuildContext context, TranslationProvider provider) {
    final hasText = provider.sourceText.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TextTranslationScreen(autofocus: true))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(isDark ? 0.4 : 0.6), width: 1.5),
              boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.translate_rounded, color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor, size: 18),
                          const SizedBox(width: 8),
                          Text('TEXT STUDIO', style: TextStyle(color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white54 : Colors.black38, size: 18),
                  ],
                ),
                const Spacer(),
                if (hasText) ...[
                  Text(
                    provider.sourceText,
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.translatedText,
                    style: TextStyle(fontSize: 22, color: isDark ? Colors.white : AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Row(
                    children: [
                      Text(
                        'Tap to enter text in ${AppConstants.getLanguageName(provider.sourceLanguage)}...',
                        style: TextStyle(fontSize: 20, color: isDark ? Colors.white.withOpacity(0.6) : AppTheme.primaryColor.withOpacity(0.8), fontWeight: FontWeight.w500),
                      ),
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) => Opacity(
                          opacity: _pulseAnimation.value,
                          child: Container(
                            width: 3,
                            height: 24,
                            margin: const EdgeInsets.only(left: 4),
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const Spacer(),
                Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Auto-Detect AI Grammar Enabled', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
                    const Icon(Icons.touch_app_rounded, color: AppTheme.secondaryColor, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumActionGrid(BuildContext context, TranslationProvider trans) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = [
      {
        'title': 'Voice Hub',
        'subtitle': 'Real-time speech',
        'icon': Icons.mic_rounded,
        'color': AppTheme.secondaryColor,
        'screen': const VoiceHubScreen(),
      },
      {
        'title': 'Lens OCR',
        'subtitle': 'Camera text scan',
        'icon': Icons.camera_alt_rounded,
        'color': AppTheme.secondaryColor,
        'screen': const VisionLensScreen(),
      },
      {
        'title': 'Documents',
        'subtitle': 'PDF & Docx translate',
        'icon': Icons.description_rounded,
        'color': AppTheme.secondaryColor,
        'screen': const DocTransScreen(),
      },
      {
        'title': 'Split Talk',
        'subtitle': 'Dual-screen speech',
        'icon': Icons.call_split_rounded,
        'color': Colors.amberAccent,
        'screen': const SplitConversationScreen(),
      },
      {
        'title': 'AI Context',
        'subtitle': 'Idioms & Nuance',
        'icon': Icons.psychology_rounded,
        'color': Colors.amberAccent,
        'screen': AiContextModal(initialPhrase: trans.sourceText.isNotEmpty ? trans.sourceText : trans.translatedText),
      },
      {
        'title': 'Coach',
        'subtitle': 'Pronunciation score',
        'icon': Icons.record_voice_over_rounded,
        'color': Colors.amberAccent,
        'screen': PronunciationCoachScreen(
          targetPhrase: trans.translatedText.isNotEmpty ? trans.translatedText : 'Welcome to Aylantro AI',
          targetLang: trans.targetLanguage,
        ),
      },
    ];

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.45,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        final color = action['color'] as Color;

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => action['screen'] as Widget)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withOpacity(isDark ? 0.3 : 0.6), width: 1.2),
                  boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                          child: Icon(action['icon'] as IconData, color: color, size: 24),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white38 : Colors.black26, size: 14),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action['title'] as String,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppTheme.primaryColor, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          action['subtitle'] as String,
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, TranslationProvider provider, bool isSource) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select ${isSource ? 'Source' : 'Target'} Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryColor)),
              const SizedBox(height: 20),
              ...AppConstants.availableLanguages.entries.map((entry) => ListTile(
                title: Text(entry.value, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  if (isSource) provider.setSourceLanguage(entry.key);
                  else provider.setTargetLanguage(entry.key);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdBanner() {
    return Consumer<TranslationProvider>(
      builder: (context, provider, child) {
        if (provider.bannerAd != null) {
          return Container(
            width: provider.bannerAd!.size.width.toDouble(),
            height: provider.bannerAd!.size.height.toDouble(),
            margin: const EdgeInsets.only(top: 8),
            alignment: Alignment.center,
            child: AdWidget(ad: provider.bannerAd!),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
