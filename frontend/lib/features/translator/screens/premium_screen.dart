import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/translation_provider.dart';
import '../../../core/theme/app_theme.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  AppTheme.secondaryColor.withOpacity(0.1),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 20),
                      _buildBenefitList(context),
                      const SizedBox(height: 40),
                      _buildPricingPlans(context, provider),
                      const SizedBox(height: 40),
                      _buildFooter(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'AYLANTRO PRO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildBenefitList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const Icon(
          Icons.stars_rounded,
          size: 80,
          color: AppTheme.secondaryColor,
        ),
        const SizedBox(height: 24),
        Text(
          'Unlock the Full Power',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _benefitItem(context, Icons.auto_awesome_rounded, 'Advanced GPT-4o AI Intelligence'),
        _benefitItem(context, Icons.cloud_off_rounded, 'Offline Language Packs'),
        _benefitItem(context, Icons.mic_none_rounded, 'Unlimited Voice Conversations'),
        _benefitItem(context, Icons.description_outlined, 'Full Document Translation'),
        _benefitItem(context, Icons.block_rounded, 'Completely Ad-Free Experience'),
      ],
    );
  }

  Widget _benefitItem(BuildContext context, IconData icon, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.secondaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingPlans(
    BuildContext context,
    TranslationProvider provider,
  ) {
    return Column(
      children: [
        _planCard(
          context,
          title: 'WEEKLY',
          price: '\$2.99',
          period: '/week',
          subtitle: 'Perfect for quick trips',
          onTap: () => _handleSubscribe(context, provider),
        ),
        const SizedBox(height: 16),
        _planCard(
          context,
          title: 'MONTHLY',
          price: '\$9.99',
          period: '/month',
          subtitle: 'Most Popular',
          isPopular: true,
          onTap: () => _handleSubscribe(context, provider),
        ),
        const SizedBox(height: 16),
        _planCard(
          context,
          title: 'YEARLY',
          price: '\$49.99',
          period: '/year',
          subtitle: 'Save 58% - Best Value',
          onTap: () => _handleSubscribe(context, provider),
        ),
      ],
    );
  }

  Widget _planCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required String subtitle,
    bool isPopular = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isPopular
              ? (isDark ? AppTheme.surfaceColor : Colors.white)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPopular
                ? AppTheme.secondaryColor
                : (isDark ? Colors.white.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.3)),
            width: isPopular ? 2 : 1,
          ),
          boxShadow: isDark ? [] : [
            const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: isPopular
                          ? AppTheme.secondaryColor
                          : (isDark ? Colors.white60 : AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.black54),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TranslationProvider>(context, listen: false);

    return Column(
      children: [
        Text(
          'Subscription auto-renews. Cancel anytime in Store settings.',
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white24 : Colors.black38),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                provider.setPremium(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Purchase restored successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                'Restore Purchase',
                style: TextStyle(fontSize: 12, color: AppTheme.secondaryColor),
              ),
            ),
            Text('|', style: TextStyle(color: isDark ? Colors.white12 : Colors.black12)),
            TextButton(
              onPressed: () async {
                final url = Uri.parse('https://aylanpro.wisehivesphere.com/terms.html');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: const Text(
                'Terms of Use',
                style: TextStyle(fontSize: 12, color: AppTheme.secondaryColor),
              ),
            ),
            Text('|', style: TextStyle(color: isDark ? Colors.white12 : Colors.black12)),
            TextButton(
              onPressed: () async {
                final url = Uri.parse('https://aylanpro.wisehivesphere.com/privacy.html');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 12, color: AppTheme.secondaryColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleSubscribe(BuildContext context, TranslationProvider provider) {
    provider.setPremium(true);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Welcome to AYLANTRO PRO! All features unlocked.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
