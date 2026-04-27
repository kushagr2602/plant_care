import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/utils/image_utils.dart';

class GeminiService {
  final String apiKey;
  static const _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  GeminiService({required this.apiKey});

  Future<Map<String, dynamic>> _generateContent(
    String prompt, {
    Uint8List? imageBytes,
  }) async {
    final parts = <Map<String, dynamic>>[];

    if (imageBytes != null) {
      parts.add({
        'inlineData': {
          'mimeType': 'image/jpeg',
          'data': ImageUtils.toBase64(imageBytes),
        }
      });
    }

    parts.add({'text': prompt});

    final response = await http.post(
      Uri.parse('$_endpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'parts': parts}
        ],
        'generationConfig': {
          'temperature': 1,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
    return _parseJson(text);
  }

  Map<String, dynamic> _parseJson(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```[a-z]*\n?'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
    }
    return jsonDecode(cleaned.trim()) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> identifyPlant(Uint8List imageBytes) async {
    return _generateContent(
      '''You are a botanist AI. Identify the plant in this image. Respond with valid JSON only, no markdown:
{
  "commonName": "string",
  "genus": "string",
  "species": "string",
  "confidence": 0.0,
  "description": "2-3 sentence plant bio",
  "careNeeds": {
    "waterFrequencyDays": 7,
    "sunlight": "full sun|partial shade|low light",
    "fertilizeFrequencyDays": 30,
    "pruneFrequencyDays": 90,
    "humidity": "low|medium|high",
    "notes": "string"
  },
  "funFacts": ["fact1", "fact2", "fact3"]
}
If the image does not contain a plant, return {"error": "not_a_plant"}.''',
      imageBytes: imageBytes,
    );
  }

  Future<Map<String, dynamic>> generateSchedule(
      String commonName, String genus, String species, Map<String, dynamic> careNeeds) async {
    return _generateContent(
      '''You are a plant care specialist. Generate a 4-week maintenance schedule for $commonName ($genus $species).

Care profile: ${jsonEncode(careNeeds)}

Return JSON only, no markdown:
{
  "weeklyTasks": [
    {
      "dayOffset": 0,
      "type": "watering|sunlight|fertilizing|pruning|misting|repotting",
      "timeOfDay": "morning|afternoon|evening",
      "durationMinutes": 5,
      "notes": "string",
      "xpReward": 10
    }
  ]
}
dayOffset goes from 0 to 27 (4 weeks). Be realistic about frequency — don't schedule more than needed.''',
    );
  }

  Future<Map<String, dynamic>> diagnosePlant(
      Uint8List imageBytes, {String? plantName}) async {
    final plantContext = plantName != null ? ' (plant: $plantName)' : '';
    return _generateContent(
      '''You are a plant pathologist AI. Analyze this photo of a potentially sick or stressed plant$plantContext and diagnose the problem. Return JSON only, no markdown:
{
  "issue": "short issue name",
  "severity": "mild|moderate|severe",
  "description": "2-3 sentences",
  "symptoms": ["symptom1", "symptom2"],
  "recoverySteps": [
    "immediate action step",
    "step 2",
    "step 3"
  ],
  "estimatedRecoveryDays": 7,
  "preventionTips": ["tip1", "tip2"]
}
If the plant appears healthy, return {"issue": "healthy", "severity": "none", "description": "Your plant looks healthy!", "symptoms": [], "recoverySteps": [], "estimatedRecoveryDays": 0, "preventionTips": []}.''',
      imageBytes: imageBytes,
    );
  }
}
