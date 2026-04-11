import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get openRouterApiKey =>
      dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String aiModel = 'nvidia/nemotron-nano-12b-v2-vl:free';

  static const String aiPrompt =
      "Analyze the waste in this image and assign the correct Bin Color based on these rules:\n"
      "- ORGANIC (Banana peels, food, leaves): GREEN BIN.\n"
      "- RECYCLABLE (Plastic bottles, Paper, Cans): BLUE BIN.\n"
      "- GLASS/HAZARDOUS: YELLOW OR RED BIN.\n\n"
      "Return ONLY a JSON object:\n"
      "{\n"
      "  \"category\": \"Organic/Plastic/etc\",\n"
      "  \"bin_color\": \"Green/Blue/Yellow\",\n"
      "  \"points\": 10,\n"
      "  \"co2_saved\": 0.5,\n"
      "  \"message\": \"Great job recycling this!\"\n"
      "}";
}