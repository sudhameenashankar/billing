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
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) async {
          if (value.isNotEmpty && value.first.path.endsWith('.json')) {
            final file = File(value.first.path);
            final jsonStr = await file.readAsString();
            try {
              final newContacts = ContactsService.importContactsJson(jsonStr);
              await ContactsService.mergeContacts(newContacts);
              onContactsImported();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contacts imported from shared JSON!'),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to import contacts from JSON.'),
                ),
              );
            }
          }
        }, onError: (err) {});
  }

  static void stopListening() {
    _intentDataStreamSubscription?.cancel();
  }
}
