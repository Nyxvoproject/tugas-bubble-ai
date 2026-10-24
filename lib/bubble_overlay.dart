import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_service.dart';
import 'answer_sheet.dart';
import 'screen_capture.dart';

/// Ini adalah UI terpisah yang dirender di dalam overlay window
/// (dipanggil lewat FlutterOverlayWindow.showOverlay + overlayMain()).
class BubbleOverlay extends StatefulWidget {
  const BubbleOverlay({super.key});

  @override
  State<BubbleOverlay> createState() => _BubbleOverlayState();
}

class _BubbleOverlayState extends State<BubbleOverlay> {
  bool _menuOpen = false;
  bool _showAnswer = false;
  bool _loading = false;
  String _answer = '';

  Future<void> _handleScreenshot() async {
    setState(() {
      _menuOpen = false;
      _showAnswer = true;
      _loading = true;
      _answer = '';
    });
    final bytes = await ScreenCapture.captureOnce();
    if (bytes == null) {
      setState(() {
        _loading = false;
        _answer = 'Gagal mengambil screenshot. Pastikan izin screen capture sudah diberikan.';
      });
      return;
    }
    final result = await AiService.solveFromImage(bytes);
    setState(() {
      _loading = false;
      _answer = result;
    });
  }

  Future<void> _handleCamera() async {
    setState(() => _menuOpen = false);
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file == null) return;

    setState(() {
      _showAnswer = true;
      _loading = true;
      _answer = '';
    });
    final Uint8List bytes = await file.readAsBytes();
    final result = await AiService.solveFromImage(bytes);
    setState(() {
      _loading = false;
      _answer = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.topRight,
          children: [
            if (_showAnswer)
              Positioned(
                top: 70,
                right: 8,
                child: AnswerSheet(
                  text: _answer,
                  loading: _loading,
                  onClose: () => setState(() => _showAnswer = false),
                ),
              ),
            if (_menuOpen)
              Positioned(
                top: 70,
                right: 8,
                child: _MenuCard(
                  onScreenshot: _handleScreenshot,
                  onCamera: _handleCamera,
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => setState(() {
                  _menuOpen = !_menuOpen;
                  _showAnswer = false;
                }),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6C4CF1),
                    boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8)],
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final VoidCallback onScreenshot;
  final VoidCallback onCamera;

  const _MenuCard({required this.onScreenshot, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuItem(icon: Icons.screenshot_monitor, label: 'Scan Layar', onTap: onScreenshot),
            const SizedBox(height: 6),
            _MenuItem(icon: Icons.camera_alt, label: 'Foto Soal', onTap: onCamera),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
