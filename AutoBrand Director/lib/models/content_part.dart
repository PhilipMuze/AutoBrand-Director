/// Represents a single part of the Gemini response.
/// Can be text or a storage URL for a generated image.
class ContentPart {
  final String? text;
  final String? mimeType;
  final String? storageUrl;

  ContentPart({this.text, this.mimeType, this.storageUrl});

  factory ContentPart.fromJson(Map<String, dynamic> json) {
    // Text part
    if (json.containsKey('text')) {
      return ContentPart(text: json['text']);
    }

    // New format: storageUrl only (no raw base64)
    if (json.containsKey('storageUrl')) {
      return ContentPart(
        storageUrl: json['storageUrl'],
        mimeType: json['mimeType'] ?? json['mime_type'],
      );
    }

    // Legacy: inlineData with storageUrl
    if (json.containsKey('inlineData')) {
      final inlineData = json['inlineData'] as Map<String, dynamic>;
      return ContentPart(
        mimeType: inlineData['mimeType'] ?? inlineData['mime_type'],
        storageUrl: json['storageUrl'],
      );
    }

    // Legacy: snake_case
    if (json.containsKey('inline_data')) {
      final inlineData = json['inline_data'] as Map<String, dynamic>;
      return ContentPart(
        mimeType: inlineData['mime_type'] ?? inlineData['mimeType'],
        storageUrl: json['storageUrl'],
      );
    }

    return ContentPart();
  }

  bool get isText => text != null;
  bool get isImage => storageUrl != null;
}
