import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/translation_provider.dart';
import '../../auth/screens/auth_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _historyItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  Future<void> _fetchHistory() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn || auth.token == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://aylanpro.wisehivesphere.com/api/history'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _historyItems = data['history'] ?? [];
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _clearHistory() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final trans = Provider.of<TranslationProvider>(context, listen: false);

    // Clear local cache first
    await trans.clearLocalHistory();

    if (!auth.isLoggedIn || auth.token == null) {
      setState(() => _historyItems.clear());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Local history cleared successfully')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse('https://aylanpro.wisehivesphere.com/api/history'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );
      if (response.statusCode == 200) {
        setState(() => _historyItems.clear());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All history cleared successfully')),
          );
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  List<dynamic> _getMergedItems(List<dynamic> cloudItems, List<Map<String, dynamic>> localItems) {
    final Set<String> seen = {};
    final List<dynamic> merged = [];

    // Helper to extract translation identifier
    String makeKey(dynamic item) {
      final sText = (item['sourceText'] ?? '').toString().trim().toLowerCase();
      final tText = (item['translatedText'] ?? '').toString().trim().toLowerCase();
      return '${sText}_${tText}';
    }

    // Add local items first (newer translations)
    for (final item in localItems) {
      final key = makeKey(item);
      if (key.isNotEmpty && !seen.contains(key)) {
        seen.add(key);
        merged.add(item);
      }
    }

    // Add cloud items
    for (final item in cloudItems) {
      final key = makeKey(item);
      if (key.isNotEmpty && !seen.contains(key)) {
        seen.add(key);
        merged.add(item);
      }
    }

    return merged;
  }

  Widget _buildSyncBanner(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_queue_rounded, color: AppTheme.secondaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cloud Sync Disabled',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondaryColor),
                ),
                const SizedBox(height: 2),
                Text(
                  'Log in to backup your translation history across all devices.',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            ).then((_) => _fetchHistory()),
            child: const Text('Log In', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final trans = Provider.of<TranslationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mergedItems = _getMergedItems(_historyItems, trans.localHistory);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (mergedItems.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.white,
              ),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.secondaryColor),
            )
          : mergedItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!auth.isLoggedIn) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildSyncBanner(context, isDark),
                        ),
                        const SizedBox(height: 40),
                      ],
                      Icon(
                        Icons.history_rounded,
                        size: 80,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No translation history yet',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mergedItems.length + (!auth.isLoggedIn ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (!auth.isLoggedIn && index == 0) {
                      return _buildSyncBanner(context, isDark);
                    }
                    final itemIndex = !auth.isLoggedIn ? index - 1 : index;
                    final item = mergedItems[itemIndex];
                    final bool showAd = (itemIndex + 1) % 5 == 0;

                    return Column(
                      children: [
                        if (showAd)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16, top: 4),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppTheme.primaryColor.withOpacity(0.3), AppTheme.secondaryColor.withOpacity(0.1)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.accentColor.withOpacity(0.5), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: AppTheme.accentColor.withOpacity(0.2), shape: BoxShape.circle),
                                  child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.accentColor, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                        child: const Text('SPONSORED', style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text('Aylantro Premium AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('Unlock unlimited offline packs & real-time document OCR', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.accentColor, size: 16),
                              ],
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.primaryColor.withOpacity(0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.5),
                              width: 1,
                            ),
                            boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppTheme.secondaryColor.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '${item['sourceLanguage'].toString().toUpperCase()} ➔ ${item['targetLanguage'].toString().toUpperCase()}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['sourceText'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                item['translatedText'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
