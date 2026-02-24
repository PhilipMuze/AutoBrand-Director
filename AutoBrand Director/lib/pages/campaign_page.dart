import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/content_part.dart';
import '../services/api_service.dart';
import '../widgets/image_block.dart';
import '../widgets/text_block.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({super.key});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _api = ApiService("https://YOUR_CLOUD_RUN_URL");

  List<ContentPart> _parts = [];
  bool _loading = false;

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _parts = [];
    });

    try {
      final result = await _api.generateCampaign(_controller.text);

      setState(() {
        _parts = result;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildPart(ContentPart part) {
    if (part.text != null) {
      return TextBlock(text: part.text!);
    }

    if (part.base64Data != null) {
      return ImageBlock(bytes: base64Decode(part.base64Data!));
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AutoBrand Director")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Enter Campaign Brief",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _generate,
              child: const Text("Generate Campaign"),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: _parts.length,
                itemBuilder: (context, index) {
                  return _buildPart(_parts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
