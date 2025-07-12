import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

bool isValidGstin(String gstin) {
  final gstinRegex = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  );
  return gstinRegex.hasMatch(gstin);
}

String toPascalCase(String input) {
  return input
      .split(RegExp(r'[_\s]+'))
      .map(
        (word) =>
            word.isEmpty
                ? ''
                : word[0].toUpperCase() + word.substring(1).toLowerCase(),
      )
      .join(' ');
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

Future<String?> scanGstinFromImage(
  BuildContext context,
  ImageSource source,
) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);
  if (pickedFile == null) return null;

  final inputImage = InputImage.fromFilePath(pickedFile.path);
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final RecognizedText recognizedText = await textRecognizer.processImage(
    inputImage,
  );

  // GSTIN regex (no word boundaries, allows GSTIN to be embedded in other text)
  final gstinRegex = RegExp(
    r'[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}',
  );
  String? foundGstin;

  for (final block in recognizedText.blocks) {
    for (final line in block.lines) {
      final cleaned = line.text.replaceAll(' ', '');
      final match = gstinRegex.firstMatch(cleaned);
      if (match != null) {
        foundGstin = match.group(0);
        break;
      }
    }
    if (foundGstin != null) break;
  }
  await textRecognizer.close();
  return foundGstin;
}
