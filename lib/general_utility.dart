String numberToWords(int number) {
  // For demo: you can use a package like 'number_to_words' for full support
  // This is a simple version for numbers < 10000
  final units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
  ];
  final teens = [
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];
  final tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  if (number == 0) return 'Zero';
  if (number < 10) return units[number];
  if (number < 20) return teens[number - 10];
  if (number < 100) {
    return tens[number ~/ 10] +
        (number % 10 != 0 ? ' ${units[number % 10]}' : '');
  }
  if (number < 1000) {
    return '${units[number ~/ 100]} Hundred${number % 100 != 0 ? ' and ${numberToWords(number % 100)}' : ''}';
  }
  if (number < 10000) {
    return '${units[number ~/ 1000]} Thousand${number % 1000 != 0 ? ' ${numberToWords(number % 1000)}' : ''}';
  }
  return number.toString();
}
