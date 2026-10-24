import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service pemanggil Gemini API (multimodal: gambar + teks -> jawaban teks).
/// Model "flash" dipakai karena murah & cepat, cocok untuk kebutuhan ini.
class AiService {
  static const _model = 'gemini-2.0-flash';
  static const _prefKey = 'gemini_api_key';

  static Future<void> saveApiKey(String key) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_prefKey, key.trim());
  }

  static Future<String?> getApiKey() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_prefKey);
  }

  /// Kirim gambar soal (bytes) + instruksi ke Gemini, kembalikan jawaban.
  static Future<String> solveFromImage(Uint8List imageBytes) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return 'API key belum diatur. Buka menu Pengaturan di app dan masukkan Gemini API key kamu (ambil gratis di aistudio.google.com/apikey).';
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Ini adalah screenshot/foto soal tugas sekolah. Baca soalnya, lalu jawab dengan jelas: "
                  "1) Tuliskan ulang soal secara singkat, 2) Berikan jawaban/langkah penyelesaiannya, "
                  "3) Jika pilihan ganda, sebutkan jawaban yang benar. Jawab dalam Bahasa Indonesia, ringkas dan mudah dipahami."
            },
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Encode(imageBytes),
              }
            }
          ]
        }
      ],
      "generationConfig": {"temperature": 0.3, "maxOutputTokens": 1024}
    });

    try {
      final res = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 30));

      if (res.statusCode != 200) {
        return 'Gagal memanggil AI (${res.statusCode}): ${res.body}';
      }

      final data = jsonDecode(res.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text ?? 'AI tidak memberikan jawaban. Coba ulangi.';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }
}
