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
