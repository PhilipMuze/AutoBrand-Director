import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/content_part.dart';
import '../models/campaign_message.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<ContentPart>> generateCampaign(String uid, String prompt, {String? imageBase64}) async {
    final Map<String, dynamic> body = {
      'uid': uid,
      'prompt': prompt
    };
    if (imageBase64 != null) {
      body['image_base64'] = imageBase64;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/generate-campaign'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate campaign: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final List parts = data['output'];

    return parts.map((e) => ContentPart.fromJson(e)).toList();
  }

  Future<List<CampaignMessage>> fetchCampaigns(String uid) async {
    final response = await http.get(
      Uri.parse('$baseUrl/campaigns/$uid'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch campaigns: ${response.statusCode}: ${response.body}');
    }

    final List data = jsonDecode(response.body);
    
    // Convert backend campaigns data into CampaignMessage objects
    List<CampaignMessage> history = [];
    for (var campaign in data.reversed) {
       // Add user prompt as a message
       history.add(CampaignMessage(
         text: campaign['prompt'],
         isUser: true,
       ));
       
       // Add AI response as a message
       final List rawOutput = campaign['output'] ?? [];
       history.add(CampaignMessage(
         isUser: false,
         parts: rawOutput.map((e) => ContentPart.fromJson(e)).toList(),
       ));
    }
    
    return history;
  }
}
