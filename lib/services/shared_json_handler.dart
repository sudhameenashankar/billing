import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../services/contacts_service.dart';

class SharedJsonHandler {
  static StreamSubscription? _intentDataStreamSubscription;

  static void startListening(
    BuildContext context,
    VoidCallback onContactsImported,
  ) {
    // Check for initial shared media (when app is launched from sharing)
    ReceiveSharingIntent.instance.getInitialMedia().then((
      List<SharedMediaFile> value,
    ) {
      if (value.isNotEmpty && value.first.path.endsWith('.json')) {
        _processJsonFile(value.first.path, context, onContactsImported);
      }
    });

    // Listen to media stream (for files shared while app is running)
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) async {
          if (value.isNotEmpty && value.first.path.endsWith('.json')) {
            _processJsonFile(value.first.path, context, onContactsImported);
          }
        }, onError: (err) {});
  }

  static void _processJsonFile(
    String filePath,
    BuildContext context,
    VoidCallback onContactsImported,
  ) async {
    final ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(
      context,
    );
    try {
      final file = File(filePath);
      final jsonStr = await file.readAsString();
      final newContacts = ContactsService.importContactsJson(jsonStr);

      await ContactsService.mergeContacts(newContacts);
      onContactsImported();
      scaffoldMessengerState.showSnackBar(
        const SnackBar(content: Text('Contacts imported from shared JSON!')),
      );
    } catch (e) {
      scaffoldMessengerState.showSnackBar(
        const SnackBar(content: Text('Failed to import contacts from JSON.')),
      );
    }
  }

  static void stopListening() {
    _intentDataStreamSubscription?.cancel();
  }
}
