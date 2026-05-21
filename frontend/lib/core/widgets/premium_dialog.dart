import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/translator/screens/premium_screen.dart';

class PremiumDialog extends StatelessWidget {
  const PremiumDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PremiumDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkSurfaceColor : Colors.white;
    final textPrimary = isDark ? Colors.white : AppTheme.primaryColor;
    final textSecondary = isDark ? Colors.white.withOpacity(0.6) : Colors.black87;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
          boxShadow: isDark ? [
            BoxShadow(color: AppTheme.secondaryColor.withOpacity(0.2), blurRadius: 30),
          ] : [
            const BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars_rounded, color: AppTheme.secondaryColor, size: 60),
            ),
            const SizedBox(height: 24),
            Text(
              'UNLOCK PREMIUM',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Remove all ads and get unlimited access to AI translation features.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PremiumScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text('UPGRADE NOW', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Maybe later',
                style: TextStyle(color: isDark ? Colors.white.withOpacity(0.4) : Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
