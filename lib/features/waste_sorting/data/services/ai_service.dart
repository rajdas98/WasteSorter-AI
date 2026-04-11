// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:wastesorter/core/errors/app_exception.dart';
import 'package:wastesorter/core/constants.dart';

class AIService {
  AIService(this._dio);

  final Dio _dio;
  static const List<String> _modelPriority = <String>[
    'nvidia/nemotron-nano-12b-v2-vl:free',
    'mistralai/pixtral-12b:free',
  ];

  Future<Map<String, dynamic>> analyzeWasteImage(String base64Image) async {
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final Object? apiKeyObject = AppConstants.openRouterApiKey;
    final String? apiKey = apiKeyObject as String?;
    final String keyPrefix = (apiKey == null || apiKey.isEmpty)
        ? 'null'
        : apiKey.substring(0, apiKey.length >= 5 ? 5 : apiKey.length);
    print('DEBUG: API Key starting with: $keyPrefix...');

    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_KEY_HERE') {
      print('FATAL: API Key is not loaded correctly from .env');
      print('ERROR: API KEY MISSING IN .env');
      throw AppException('Missing API key in .env');
    }

    AppException? lastError;
    for (final String model in _modelPriority) {
      try {
        return await _sendRequest(
          model: model,
          base64Image: base64Image,
          apiKey: apiKey,
        );
      } on DioException catch (e) {
        print('OpenRouter raw error: ${e.response?.data}');
        print('DIO ERROR TYPE: ${e.type}');
        print('DIO ERROR MESSAGE: ${e.message}');
        print('DEBUG: Full Error: ${e.response?.data}');
        final int? status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          throw AppException('API Key Error: Please check your .env file.');
        }
        if (status == 429) {
          print('Rate limited on $model. Waiting 3 seconds before fallback...');
          await Future<void>.delayed(const Duration(seconds: 3));
          lastError = AppException('AI is busy, please try in a few seconds.');
          continue;
        }
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          if (e.type == DioExceptionType.connectionError) {
            print(
              'STRICT DEBUG: This might be a CORS issue on Windows 7 Chrome.',
            );
          }
          lastError = AppException(
            'Upload/network issue. Try smaller image or retry. ${_first50(e.message ?? 'unknown error')}',
          );
          continue;
        }
        lastError = AppException(
          'AI is busy, please try in a few seconds.',
        );
      } on FormatException {
        lastError = AppException('AI is busy, please try in a few seconds.');
      } catch (_) {
        lastError = AppException('AI is busy, please try in a few seconds.');
      }
    }

    throw lastError ?? AppException('All models failed. Please retry.');
  }

  Future<Map<String, dynamic>> _sendRequest({
    required String model,
    required String base64Image,
    required String apiKey,
  }) async {
    final Uint8List rawBytes = base64Decode(base64Image);
    final Uint8List imageBytes = _compressImage(rawBytes);
    print('DEBUG: Image size in bytes: ${imageBytes.length}');
    if (model == 'nvidia/nemotron-nano-12b-v2-vl:free') {
      print('🔍 ANALYZING WASTE WITH NVIDIA VL...');
    }
    print('TRYING MODEL: $model');
    print('Sending request to OpenRouter...');

    final String prefixedBase64 =
        'data:image/jpeg;base64,${base64Encode(imageBytes)}';
    final response = await _dio.post(
      '${AppConstants.openRouterBaseUrl}/chat/completions',
      options: Options(
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        sendTimeout: const Duration(seconds: 45),
        headers: <String, String>{
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'HTTP-Referer': 'https://wastesorter-ai.local',
          'HTTP_REFERER': 'https://wastesorter-ai.local',
          'X-Title': 'WasteSorter AI (Kachra Pehchano)',
        },
      ),
      data: jsonEncode(<String, dynamic>{
        'model': model,
        'messages': <Map<String, dynamic>>[
          <String, dynamic>{
            'role': 'user',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'text',
                'text': AppConstants.aiPrompt,
              },
              <String, dynamic>{
                'type': 'image_url',
                'image_url': <String, String>{
                  'url': prefixedBase64,
                },
              },
            ],
          },
        ],
      }),
    );

    print('RAW RESPONSE: ${response.data}');
    final dynamic contentRaw = response.data['choices'][0]['message']['content'];
    final String content = contentRaw.toString();
    final String cleaned = _extractJson(content);
    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } on FormatException {
      print('DEBUG: Invalid JSON raw response: $content');
      print('DEBUG: Full response on failure: ${response.data}');
      rethrow;
    }
  }

  String _extractJson(String content) {
    final RegExp fenced = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final RegExpMatch? fencedMatch = fenced.firstMatch(content);
    if (fencedMatch != null) {
      return fencedMatch.group(1)!.trim();
    }

    final RegExp anyObject = RegExp(r'\{[\s\S]*\}');
    final RegExpMatch? jsonMatch = anyObject.firstMatch(content);
    if (jsonMatch != null) {
      return jsonMatch.group(0)!.trim();
    }

    return content.trim();
  }

  String _first50(String message) {
    return message.length <= 50 ? message : message.substring(0, 50);
  }

  Uint8List _compressImage(Uint8List sourceBytes) {
    final img.Image? decoded = img.decodeImage(sourceBytes);
    if (decoded == null) {
      return sourceBytes;
    }

    final int originalWidth = decoded.width;
    final int originalHeight = decoded.height;
    final int maxSide = originalWidth > originalHeight
        ? originalWidth
        : originalHeight;

    img.Image resized = decoded;
    if (maxSide > 400) {
      final double scale = 400 / maxSide;
      final int newWidth = (originalWidth * scale).round();
      final int newHeight = (originalHeight * scale).round();
      resized = img.copyResize(decoded, width: newWidth, height: newHeight);
    }

    return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
  }
}
