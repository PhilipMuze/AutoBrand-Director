/// Represents a single part of the Gemini response.
/// Can be text, an inline image (base64), or a storage URL for a generated image.
class ContentPart {
  final String? text;
  final String? mimeType;
  final String? base64Data;
  final String? storageUrl;

  ContentPart({this.text, this.mimeType, this.base64Data, this.storageUrl});

  /// Parses both camelCase (from Gemini SDK) and snake_case (legacy) formats.
  factory ContentPart.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('text')) {
      return ContentPart(text: json['text']);
    }

    // Handle camelCase format (from Gemini 2.0 SDK response via our backend)
    if (json.containsKey('inlineData')) {
      final inlineData = json['inlineData'] as Map<String, dynamic>;
      return ContentPart(
        mimeType: inlineData['mimeType'] ?? inlineData['mime_type'],
        base64Data: inlineData['data'],
        storageUrl: json['storageUrl'],
      );
    }

    // Handle snake_case format (legacy compatibility)
    if (json.containsKey('inline_data')) {
      final inlineData = json['inline_data'] as Map<String, dynamic>;
      return ContentPart(
        mimeType: inlineData['mime_type'] ?? inlineData['mimeType'],
        base64Data: inlineData['data'],
        storageUrl: json['storageUrl'],
      );
    }

    return ContentPart();
  }

  bool get isText => text != null;
  bool get isImage => base64Data != null;
}
