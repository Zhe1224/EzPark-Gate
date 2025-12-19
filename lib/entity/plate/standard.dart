// ignore_for_file: deprecated_member_use
import 'plate.dart';

class StandardPlate extends Plate {
  final String _space = " ";
  final String _prefix;
  final String _number;
  final String _suffix;

  StandardPlate._(this._prefix, this._number, this._suffix);

  @override
  String toString() {
    String output = _prefix + _space + _number;
    if (_suffix.isNotEmpty) output += _space + _suffix;
    return output;
  }

  factory StandardPlate.fromText(String input){
    // Logic to extract prefix, number, and suffix for standard plates.
    // Trim the input string and split into groups
    List<String> groups = input.trim().split(RegExp(r'\s+'));
    if (groups.length < 2 || groups.length > 3) {
      throw FormatException('Invalid number of groups; expected 2 or 3.');
    }

    String prefix = groups[0];
    String number = groups[1];
    String suffix = groups.length == 3 ? groups[2] : "";

    // Normalize the prefix and suffix (group 1 and 3)
    prefix = _normalizeLetters(prefix);
    if (suffix.isNotEmpty) {
      suffix = _normalizeLetters(suffix);
    }

    // Normalize the number (group 2)
    number = _normalizeNumbers(number);

    // Validate groups
    if (!_validatePrefix(prefix)) {
      throw FormatException('Invalid prefix format; must be 1-3 letters.');
    }
    if (!_validateNumber(number)) {
      throw FormatException('Invalid number format; must be 1-4 digits.');
    }
    if (suffix.isNotEmpty && !_validateSuffix(suffix)) {
      throw FormatException('Invalid suffix format; must be 1 letter.');
    }
    return StandardPlate._(prefix, number, suffix);
  }

  // Normalize letters by replacing homoglyphs and casting to upper case
  static String _normalizeLetters(String input) {
    final homoglyphs = {
      '0': 'O',
      '1': 'I',
      '5': 'S',
      '2': 'Z',
      '8': 'B',
      // Additional homoglyphs can be added here
    };

    StringBuffer normalized = StringBuffer();
    for (var char in input.split('')) {
      // Convert lowercase letters to uppercase and replace homoglyphs
      if (RegExp(r'[a-z]').hasMatch(char)) {
        normalized.write(char.toUpperCase());
      } else {
        normalized.write(homoglyphs[char] ?? char);
      }
    }

    return normalized.toString();
  }

  // Normalize numbers by replacing letters with numbers
  static String _normalizeNumbers(String input) {
    final letterToNumber = {
      'O': '0',
      'I': '1',
      'S': '5',
      'Z': '2',
      'B': '8',
      // Additional mappings can be added here
    };

    StringBuffer normalized = StringBuffer();
    for (var char in input.split('')) {
      // Replace characters with their corresponding numbers
      normalized.write(letterToNumber[char] ?? char);
    }

    return normalized.toString();
  }

  // Validate the prefix (1-3 letters)
  static bool _validatePrefix(String prefix) {
    return RegExp(r'^[A-Z]{1,3}$').hasMatch(prefix);
  }

  // Validate the number (1-4 digits)
  static bool _validateNumber(String number) {
    return RegExp(r'^\d{1,4}$').hasMatch(number);
  }

  // Validate the suffix (1 optional letter)
  static bool _validateSuffix(String suffix) {
    return RegExp(r'^[A-Z]$').hasMatch(suffix);
  }
}