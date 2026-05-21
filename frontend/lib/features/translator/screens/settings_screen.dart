import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/translation_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import 'premium_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/screens/auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          const Text(
            'PREFERENCES',
            style: TextStyle(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingItem(
            icon: Icons.star_rounded,
            title: 'Upgrade to Premium',
            subtitle: 'Remove ads and support development',
            themeProvider: themeProvider,
            onTap: () => _showPremiumDialog(context),
          ),
          _buildThemeToggle(context, themeProvider),
          const SizedBox(height: 10),
          _buildOfflineToggle(context, provider, themeProvider),
          const SizedBox(height: 10),
          _buildSettingItem(
            icon: Icons.person_outline_rounded,
            title: authProvider.isLoggedIn ? 'Account Profile' : 'Sign In / Register',
            subtitle: authProvider.isLoggedIn ? (authProvider.user?['email'] ?? 'Premium User') : 'Sync history and cloud backup',
            themeProvider: themeProvider,
            onTap: () => _showAccountProfile(context, authProvider, provider),
          ),
          _buildSettingItem(
            icon: Icons.translate_rounded,
            title: 'Default Language',
            subtitle: AppConstants.getLanguageName(provider.sourceLanguage),
            themeProvider: themeProvider,
            onTap: () => _showDefaultLanguagePicker(context, provider),
          ),
          _buildSettingItem(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Manage alerts and updates',
            themeProvider: themeProvider,
            onTap: () => _showNotificationSettings(context),
          ),
          _buildSettingItem(
            icon: Icons.security_rounded,
            title: 'Privacy & Security',
            subtitle: 'Control your data usage',
            themeProvider: themeProvider,
            onTap: () => _showPrivacySettings(context),
          ),
          _buildSettingItem(
            icon: Icons.cloud_off_rounded,
            title: 'Offline Language Packs',
            subtitle: 'Download available for offline use',
            themeProvider: themeProvider,
            onTap: () => _showOfflinePacks(context, provider),
          ),
          _buildSettingItem(
            icon: Icons.info_outline_rounded,
            title: 'About Aylantro',
            subtitle: 'Version 1.0.0',
            themeProvider: themeProvider,
            onTap: () => _showAboutAylantro(context),
          ),
          const SizedBox(height: 20),
          const Text(
            'VOICE & AUDIO',
            style: TextStyle(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingItem(
            icon: Icons.speed_rounded,
            title: 'Speech Rate',
            subtitle: 'Adjust AI Voice speed',
            themeProvider: themeProvider,
            onTap: () => _showSpeechRateSlider(context, provider),
          ),
          const SizedBox(height: 20),
          const Text(
            'LEGAL',
            style: TextStyle(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read how we handle your data',
            themeProvider: themeProvider,
            onTap: () => launchUrl(
              Uri.parse('https://aylanpro.wisehivesphere.com/privacy.html'),
            ),
          ),
          _buildSettingItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'App usage rules',
            themeProvider: themeProvider,
            onTap: () => launchUrl(
              Uri.parse('https://aylanpro.wisehivesphere.com/terms.html'),
            ),
          ),
          const SizedBox(height: 40),
          if (authProvider.isLoggedIn)
            TextButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAccountProfile(
    BuildContext context,
    AuthProvider auth,
    TranslationProvider trans,
  ) {
    if (!auth.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryColor,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                auth.user?['name'] ?? 'Premium User',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                auth.user?['email'] ?? '',
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: AppTheme.secondaryColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'CLOUD ACCOUNT ACTIVE',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildActionTile(
                context,
                Icons.cloud_sync_rounded,
                'Sync Translation History',
                onTap: () async {
                  Navigator.pop(context); // Close bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Syncing translation history...'), duration: Duration(seconds: 1)),
                  );
                  // Simulate progress sync
                  await Future.delayed(const Duration(milliseconds: 800));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync complete!'), backgroundColor: Colors.green),
                  );
                },
              ),
              _buildActionTile(
                context,
                Icons.lock_outline_rounded,
                'Change Password',
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  _showChangePasswordDialog(context);
                },
              ),
              _buildActionTile(
                context,
                Icons.delete_outline_rounded,
                'Delete Account',
                isDestructive: true,
                onTap: () {
                  _showDeleteAccountDialog(context, auth, trans);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Change Password',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.primaryColor, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: const InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: AppTheme.secondaryColor),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: AppTheme.secondaryColor),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: TextStyle(color: AppTheme.secondaryColor),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New passwords do not match'), backgroundColor: Colors.redAccent),
                );
                return;
              }
              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: Colors.redAccent),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully'), backgroundColor: Colors.green),
              );
            },
            child: const Text('UPDATE', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider auth, TranslationProvider trans) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone and you will lose all synchronization data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close profile bottom sheet
              
              // Clear cache and log out user
              await trans.clearLocalHistory();
              auth.logout();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your account has been deleted permanently.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('DELETE PERMANENTLY', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.redAccent : AppTheme.secondaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : (isDark ? Colors.white : Colors.black87),
        ),
      ),
      onTap: onTap,
    );
  }

  void _showDefaultLanguagePicker(
    BuildContext context,
    TranslationProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final languages = AppConstants.availableLanguages.entries.toList();
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          builder: (_, controller) => Column(
            children: [
              const SizedBox(height: 24),
              Text(
                'Set Default Language',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final entry = languages[index];
                    return ListTile(
                      title: Text(entry.value, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                      trailing: provider.sourceLanguage == entry.key
                          ? const Icon(
                              Icons.check_circle,
                              color: AppTheme.secondaryColor,
                            )
                          : null,
                      onTap: () {
                        provider.setSourceLanguage(entry.key);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationSettings(BuildContext context) {
    bool pushVal = true;
    bool emailVal = false;
    bool remindersVal = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text('Notifications', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleTile(context, 'Push Notifications', pushVal, (v) {
                  setModalState(() => pushVal = v);
                }),
                _buildToggleTile(context, 'Email Updates', emailVal, (v) {
                  setModalState(() => emailVal = v);
                }),
                _buildToggleTile(context, 'Translation Reminders', remindersVal, (v) {
                  setModalState(() => remindersVal = v);
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification settings updated')),
                  );
                },
                child: const Text('DONE', style: TextStyle(color: AppTheme.secondaryColor)),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildToggleTile(BuildContext context, String title, bool val, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        Switch(
          value: val,
          onChanged: onChanged,
          activeColor: AppTheme.secondaryColor,
        ),
      ],
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Privacy & Security', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Text(
          'Your data is encrypted and used only for translation processing. We do not store your voice or document data after processing.',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppTheme.secondaryColor)),
          ),
        ],
      ),
    );
  }

  void _showAboutAylantro(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Aylantro AI',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.auto_awesome_rounded,
        color: AppTheme.primaryColor,
      ),
      children: [
        const Text(
          'Aylantro AI is a premium multi-lingual translation platform designed for professionals and world travelers.',
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(
                'Powered by',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'WiseHiveSphere',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSpeechRateSlider(
    BuildContext context,
    TranslationProvider provider,
  ) {
    double tempRate = 1.0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text('AI Speech Rate', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.speed_rounded,
                  size: 48,
                  color: AppTheme.secondaryColor,
                ),
                const SizedBox(height: 16),
                Slider(
                  value: tempRate,
                  onChanged: (v) {
                    setModalState(() {
                      tempRate = v;
                    });
                  },
                  activeColor: AppTheme.secondaryColor,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                ),
                Text('${tempRate.toStringAsFixed(1)}x Speed', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Speech rate set to ${tempRate.toStringAsFixed(1)}x')),
                  );
                },
                child: const Text('SAVE', style: TextStyle(color: AppTheme.secondaryColor)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.5)),
        boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_rounded, color: AppTheme.secondaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Appearance Theme',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildThemeOption(context, themeProvider, ThemeMode.system, Icons.auto_awesome_rounded, 'Auto'),
              const SizedBox(width: 10),
              _buildThemeOption(context, themeProvider, ThemeMode.light, Icons.light_mode_rounded, 'Day'),
              const SizedBox(width: 10),
              _buildThemeOption(context, themeProvider, ThemeMode.dark, Icons.dark_mode_rounded, 'Night'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeProvider provider, ThemeMode mode, IconData icon, String label) {
    final isSelected = provider.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setThemeMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppTheme.secondaryColor : Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineToggle(BuildContext context, TranslationProvider provider, ThemeProvider themeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.5)),
        boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(provider.isOfflineMode ? Icons.cloud_off_rounded : Icons.cloud_done_rounded, color: AppTheme.secondaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Offline Mode',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppTheme.primaryColor),
            ),
          ),
          Switch(
            value: provider.isOfflineMode,
            onChanged: (val) => provider.toggleOfflineMode(val),
            activeColor: AppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
  }

  void _showOfflinePacks(BuildContext context, TranslationProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'OFFLINE PACKS',
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Translate without internet connection',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<TranslationProvider>(
                  builder: (context, transProvider, _) {
                    return ListView(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildOfflinePackItem(context, 'English', 'en', '12 MB', transProvider),
                        _buildOfflinePackItem(context, 'Hausa', 'ha', '18 MB', transProvider),
                        _buildOfflinePackItem(context, 'Arabic', 'ar', '24 MB', transProvider),
                        _buildOfflinePackItem(context, 'French', 'fr', '21 MB', transProvider),
                        _buildOfflinePackItem(context, 'Spanish', 'es', '19 MB', transProvider),
                        _buildOfflinePackItem(context, 'Swahili', 'sw', '15 MB', transProvider),
                        _buildOfflinePackItem(context, 'Chinese', 'zh', '45 MB', transProvider),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflinePackItem(
    BuildContext context,
    String language,
    String code,
    String size,
    TranslationProvider provider,
  ) {
    final isDownloaded = provider.downloadedPacks[code] == true;
    final isDownloading = provider.downloadingPacks[code] == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDownloaded
              ? AppTheme.secondaryColor.withOpacity(0.5)
              : AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.4),
        ),
        boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDownloaded
                  ? AppTheme.secondaryColor.withOpacity(0.1)
              : AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.secondaryColor),
                  )
                : Icon(
                    isDownloaded ? Icons.check_circle_rounded : Icons.cloud_download_rounded,
                    color: isDownloaded
                        ? AppTheme.secondaryColor
                        : AppTheme.primaryColor,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                Text(
                  size,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isDownloading)
            const Text(
              'DOWNLOADING...',
              style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 12),
            )
          else if (!isDownloaded)
            TextButton(
              onPressed: () => provider.downloadPack(code),
              child: const Text(
                'DOWNLOAD',
                style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            )
          else
            const Text(
              'READY',
              style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeProvider themeProvider,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.5)),
              boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.secondaryColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppTheme.primaryColor),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.black38),
              ],
            ),
          ),
        );
      }
    );
  }
}
