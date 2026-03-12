import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/campaign_message.dart';
import '../models/content_part.dart';
import 'image_block.dart';
import 'text_block.dart';
import 'thinking_indicator.dart';

class ChatBubble extends StatelessWidget {
  final CampaignMessage message;

  const ChatBubble({super.key, required this.message});

  Widget _buildPart(ContentPart part) {
    if (part.text != null) {
      return TextBlock(text: part.text!);
    }

    if (part.base64Data != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ImageBlock(bytes: base64Decode(part.base64Data!)),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    bool isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                    : const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isThinking)
                    const ThinkingIndicator()
                  else if (isUser) ...[
                    if (message.base64Image != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(message.base64Image!),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Text(message.text,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.white)),
                  ] else if (message.parts != null) ...[
                    ...message.parts!.map((part) => _buildPart(part)),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.person, color: Colors.white70, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
