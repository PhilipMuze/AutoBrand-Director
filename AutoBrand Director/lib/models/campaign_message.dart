import 'content_part.dart';

class CampaignMessage {
  final String text;
  final String? base64Image;
  final bool isUser;
  final List<ContentPart>? parts;
  final bool isThinking;

  CampaignMessage({
    this.text = "",
    this.base64Image,
    required this.isUser,
    this.parts,
    this.isThinking = false,
  });
}
