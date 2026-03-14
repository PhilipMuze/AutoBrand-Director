import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/campaign_message.dart';
import '../models/content_part.dart';
import 'text_block.dart';
import 'thinking_indicator.dart';

class ChatBubble extends StatelessWidget {
  final CampaignMessage message;

  const ChatBubble({super.key, required this.message});

  List<Widget> _buildParts(List<ContentPart> parts) {
    if (parts.isEmpty) {
      return [const SizedBox.shrink()];
    }

    final List<Widget> widgets = [];
    
    for (final part in parts) {
      if (part.isText && part.text != null && part.text!.trim().isNotEmpty) {
        widgets.add(TextBlock(text: part.text!.trim()));
      } else if (part.isImage && part.storageUrl != null) {
        widgets.add(_buildNetworkImage(part.storageUrl!));
      }
    }

    return widgets;
  }

  Widget _buildNetworkImage(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFF6366F1),
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white38,
                  size: 32,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                    : const Color(0xFF0F0F1A).withValues(alpha: 0.8),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 20),
                ),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFF818CF8).withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  if (!isUser) ...[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ],
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
                    Text(
                      message.text ,
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ] else if (message.parts != null) ...[
                    ..._buildParts(message.parts!),
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
