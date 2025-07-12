import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsService {
  static const _key = 'customers';

  static Future<List<Map<String, String>>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
  }

  static Future<void> saveContacts(List<Map<String, String>> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final list = contacts.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(_key, list);
  }

  static Future<void> mergeContacts(List<Map<String, String>> newContacts) async {
    final existing = await loadContacts();
    final Map<String, Map<String, String>> merged = {
      for (var c in existing) c['gstin']!: c
    };
    for (var c in newContacts) {
      merged[c['gstin']!] = c;
    }
    await saveContacts(merged.values.toList());
  }

  static String exportContactsJson(List<Map<String, String>> contacts) {
    return jsonEncode(contacts);
  }

  static List<Map<String, String>> importContactsJson(String jsonStr) {
    final decoded = jsonDecode(jsonStr) as List;
    return decoded.map((e) => Map<String, String>.from(e)).toList();
  }
}