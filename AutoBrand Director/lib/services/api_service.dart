import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/content_part.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<ContentPart>> generateCampaign(String prompt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-campaign'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate campaign');
    }

    final data = jsonDecode(response.body);
    final List parts = data['output'];

    return parts.map((e) => ContentPart.fromJson(e)).toList();
  }
}
