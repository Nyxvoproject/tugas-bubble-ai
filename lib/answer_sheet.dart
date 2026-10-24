import 'package:flutter/material.dart';

class AnswerSheet extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback onClose;

  const AnswerSheet({
    super.key,
    required this.text,
    required this.loading,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 420),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 16)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 18),
                const SizedBox(width: 6),
                const Text('Jawaban AI',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close, color: Colors.white70, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : Text(text, style: const TextStyle(color: Colors.white, height: 1.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
