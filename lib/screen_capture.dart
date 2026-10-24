import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Jembatan ke kode native Android (MediaProjection) untuk mengambil
/// screenshot dari apa pun yang sedang tampil di layar.
/// Implementasi native-nya ada di android/.../ScreenCaptureService.kt
class ScreenCapture {
  static const _channel = MethodChannel('tugas_bubble_ai/screen_capture');

  /// Memicu dialog izin screen-capture bawaan Android (sekali per sesi).
  static Future<bool> requestPermission() async {
    final ok = await _channel.invokeMethod<bool>('requestPermission');
    return ok ?? false;
  }

  /// Ambil satu frame screenshot layar saat ini sebagai JPEG bytes.
  static Future<Uint8List?> captureOnce() async {
    final bytes = await _channel.invokeMethod<Uint8List>('captureOnce');
    return bytes;
  }
}
