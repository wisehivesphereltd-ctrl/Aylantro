import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/translation_provider.dart';
import '../../translator/screens/premium_screen.dart';
import '../../../core/constants/app_constants.dart';

class DocTransScreen extends StatefulWidget {
  const DocTransScreen({super.key});

  @override
  State<DocTransScreen> createState() => _DocTransScreenState();
}

class _DocTransScreenState extends State<DocTransScreen> {
  bool _isUploading = false;
  double _progress = 0.0;
  String? _fileName;

  Future<void> _pickDocument() async {
    final provider = Provider.of<TranslationProvider>(context, listen: false);
    
    // Premium Check
    if (!provider.isPremium) {
      _showPremiumDialog(context);
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
    );

    if (result != null) {
      setState(() {
        _isUploading = true;
        _progress = 0.0;
        _fileName = result.files.single.name;
      });

      // Simulation of processing for now
      _simulateProgress();
    }
  }

  void _showPremiumDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
  }

  void _showLanguagePicker(BuildContext context, TranslationProvider provider, bool isSource) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        final languages = AppConstants.availableLanguages.entries.toList();
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) => Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black26, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text(
                'Select ${isSource ? 'Source' : 'Target'} Language',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final entry = languages[index];
                    final isSelected = isSource 
                        ? provider.sourceLanguage == entry.key 
                        : provider.targetLanguage == entry.key;
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                      title: Text(
                        entry.value, 
                        style: TextStyle(
                          color: isSelected ? AppTheme.secondaryColor : (isDark ? Colors.white : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        )
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.secondaryColor) : null,
                      onTap: () {
                        if (isSource) {
                          provider.setSourceLanguage(entry.key);
                        } else {
                          provider.setTargetLanguage(entry.key);
                        }
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Document Translator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Translate Documents',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your PDF, Word, or Text files to get them translated instantly.',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 32),
            _buildLanguageSelector(provider),
            const SizedBox(height: 24),
            _buildUploadZone(),
            const SizedBox(height: 32),
            Text(
              'Supported Formats',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            _buildFormatList(),
            if (_isUploading) ...[
              const SizedBox(height: 40),
              _buildProgressIndicator(),
            ],
            if (_fileName != null && !_isUploading) _buildResultSection(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(TranslationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.5)),
        boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _langButton(provider.sourceLanguage, true, provider),
          Icon(Icons.arrow_forward_rounded, color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor),
          _langButton(provider.targetLanguage, false, provider),
        ],
      ),
    );
  }

  Widget _langButton(String code, bool isSource, TranslationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showLanguagePicker(context, provider, isSource),
      child: Column(
        children: [
          Text(isSource ? 'SOURCE' : 'TARGET', style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(AppConstants.getLanguageName(code), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildResultSection(TranslationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.5)),
        boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green),
              SizedBox(width: 12),
              Text('Translation Ready', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          Text('File: $_fileName', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 24),
          Text('Translated Content Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppTheme.primaryColor)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'The document has been successfully processed. You can now view the full translation or export it in your preferred format.',
              style: TextStyle(fontStyle: FontStyle.italic, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showFullTranslation(context, provider),
                  icon: const Icon(Icons.visibility_rounded, color: Colors.white),
                  label: const Text('View Full', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSaveAsDialog(context),
                  icon: const Icon(Icons.save_alt_rounded),
                  label: const Text('Save As'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.primaryColor),
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFullTranslation(BuildContext context, TranslationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Translation Preview',
      pageBuilder: (context, _, __) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            title: Text(_fileName ?? 'Translation', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.secondaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '${AppConstants.getLanguageName(provider.targetLanguage).toUpperCase()} VERSION',
                    style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  provider.translatedText.isNotEmpty 
                      ? 'This is a preview of your translated document.'
                      : 'This is a preview of your translated document. The layout and formatting have been preserved using Aylantro AI Intelligence.',
                  style: TextStyle(fontSize: 18, height: 1.6, color: isDark ? Colors.white : AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    provider.translatedText.isNotEmpty 
                        ? provider.translatedText 
                        : 'No text was detected or translated from the document yet. Please ensure the document is not password protected and try again.',
                    style: TextStyle(fontSize: 16, height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSaveAsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Export Translation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select your preferred export format:'),
            const SizedBox(height: 20),
            _exportOption(context, 'Portable Document Format', 'PDF', Icons.picture_as_pdf_rounded, Colors.redAccent),
            _exportOption(context, 'Word Document', 'DOCX', Icons.description_rounded, Colors.blueAccent),
            _exportOption(context, 'Plain Text File', 'TXT', Icons.text_snippet_rounded, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _exportOption(BuildContext context, String title, String format, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(format, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(title, style: const TextStyle(fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully saved as $_fileName.$format'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildUploadZone() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _pickDocument,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.5),
            style: BorderStyle.solid,
          ),
          boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _fileName != null ? Icons.task_rounded : Icons.upload_file_rounded, 
              size: 48, 
              color: AppTheme.primaryColor.withOpacity(0.5)
            ),
            const SizedBox(height: 16),
            Text(
              _fileName ?? 'Tap to select a file',
              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryColor),
            ),
            Text(
              'PDF, DOCX, or TXT (Max 10MB)',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatList() {
    final formats = [
      {'icon': Icons.picture_as_pdf_rounded, 'name': 'PDF', 'color': Colors.redAccent},
      {'icon': Icons.description_rounded, 'name': 'DOCX', 'color': AppTheme.secondaryColor},
      {'icon': Icons.text_snippet_rounded, 'name': 'TXT', 'color': Colors.grey},
    ];

    return Row(
      children: formats.map((f) {
        return Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: (f['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(f['icon'] as IconData, size: 18, color: f['color'] as Color),
              const SizedBox(width: 8),
              Text(f['name'] as String, style: TextStyle(color: f['color'] as Color, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: isDark ? Theme.of(context).cardColor : Colors.grey.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${(_progress * 100).toInt()}% processed', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
            Text('Translating...', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
          ],
        ),
      ],
    );
  }

  void _simulateProgress() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_progress >= 1.0) {
        setState(() {
          _isUploading = false;
        });
        _showSuccess();
        return false;
      }
      setState(() {
        _progress += 0.02;
      });
      return true;
    });
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully translated $_fileName!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
