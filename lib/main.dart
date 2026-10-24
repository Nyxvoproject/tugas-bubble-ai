import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ai_service.dart';
import 'bubble_overlay.dart';
import 'screen_capture.dart';

/// Entry point utama (app biasa, bukan overlay).
void main() {
  runApp(const HostApp());
}

/// Entry point KHUSUS untuk overlay window.
/// flutter_overlay_window akan memanggil fungsi top-level ini di isolate terpisah.
@pragma('vm:entry-point')
void overlayMain() {
  runApp(const BubbleOverlay());
}

class HostApp extends StatelessWidget {
  const HostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C4CF1),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _apiKeyCtrl = TextEditingController();
  bool _overlayActive = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _checkOverlayStatus();
  }

  Future<void> _loadApiKey() async {
    final key = await AiService.getApiKey();
    if (key != null) _apiKeyCtrl.text = key;
  }

  Future<void> _checkOverlayStatus() async {
    final active = await FlutterOverlayWindow.isActive();
    setState(() => _overlayActive = active);
  }

  Future<void> _startBubble() async {
    final overlayGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!overlayGranted) {
      await FlutterOverlayWindow.requestPermission();
    }
    await Permission.camera.request();
    await ScreenCapture.requestPermission();

    await FlutterOverlayWindow.showOverlay(
      height: WindowSize.matchParent,
      width: WindowSize.matchParent,
      enableDrag: false,
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.none,
    );
    setState(() => _overlayActive = true);
  }

  Future<void> _stopBubble() async {
    await FlutterOverlayWindow.closeOverlay();
    setState(() => _overlayActive = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas Bubble AI')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pengaturan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _apiKeyCtrl,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'Ambil gratis di aistudio.google.com/apikey',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await AiService.saveApiKey(_apiKeyCtrl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('API key disimpan')));
                }
              },
              child: const Text('Simpan API Key'),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            Text(_overlayActive ? 'Bubble sedang aktif' : 'Bubble belum aktif',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _overlayActive ? null : _startBubble,
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Aktifkan Bubble'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _overlayActive ? _stopBubble : null,
              icon: const Icon(Icons.stop_circle),
              label: const Text('Matikan Bubble'),
            ),
          ],
        ),
      ),
    );
  }
}
