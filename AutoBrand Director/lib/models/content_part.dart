
class ContentPart {
  final String? text;
  final String? mimeType;
  final String? base64Data;

  ContentPart({this.text, this.mimeType, this.base64Data});

  factory ContentPart.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('text')) {
      return ContentPart(text: json['text']);
    }

    if (json.containsKey('inline_data')) {
      return ContentPart(
        mimeType: json['inline_data']['mime_type'],
        base64Data: json['inline_data']['data'],
      );
    }

    return ContentPart();
  }
}
