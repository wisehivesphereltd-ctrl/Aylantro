import 'dart:convert';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../providers/translation_provider.dart';
import '../../../core/theme/app_theme.dart';

class VisionLensScreen extends StatefulWidget {
  const VisionLensScreen({super.key});

  @override
  State<VisionLensScreen> createState() => _VisionLensScreenState();
}

class _VisionLensScreenState extends State<VisionLensScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Check and request permissions
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
      return;
    }

    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndProcess(TranslationProvider provider) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      await provider.ocrAndTranslate(base64Image);
      if (mounted) Navigator.pop(context); // Return to Home to see results
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Feed
          if (_isInitialized && _controller != null)
            SizedBox.expand(
              child: CameraPreview(_controller!),
            )
          else
            const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor)),
          
          // Overlay UI
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${provider.sourceLanguage} -> ${provider.targetLanguage}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: Colors.white),
                        onPressed: () {
                          if (_controller != null && _isInitialized) {
                            setState(() {
                              _isFlashOn = !_isFlashOn;
                              _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (provider.detectedText.isNotEmpty || provider.isTranslating)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.4), width: 1.5),
                          ),
                          child: provider.isTranslating 
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(color: AppTheme.secondaryColor),
                                    SizedBox(height: 16),
                                    Text('Scanning and Translating...', style: TextStyle(color: Colors.white, fontSize: 16)),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.document_scanner_rounded, color: AppTheme.secondaryColor, size: 20),
                                          SizedBox(width: 8),
                                          Text('OCR RESULT', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 20),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: '${provider.detectedText}\n\n${provider.translatedText}'));
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied OCR results to clipboard')));
                                        },
                                      ),
                                    ],
                                  ),
                                  const Divider(color: Colors.white24),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          const SizedBox(height: 8),
                                          Text(
                                            provider.detectedText,
                                            style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.5),
                                            textAlign: TextAlign.left,
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 16.0),
                                            child: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.secondaryColor, size: 28),
                                          ),
                                          Text(
                                            provider.translatedText,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.5),
                                            textAlign: TextAlign.left,
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                
                // Capture Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: GestureDetector(
                    onTap: provider.isTranslating ? null : () => _takePictureAndProcess(provider),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: provider.isTranslating ? Colors.white30 : Colors.white, 
                          width: 4
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: provider.isTranslating ? Colors.white30 : Colors.white,
                        ),
                        child: provider.isTranslating 
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                          : const Icon(Icons.camera_rounded, color: Colors.black, size: 40),
                      ),
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
}
