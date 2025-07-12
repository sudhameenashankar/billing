import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../services/contacts_service.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final contacts = await ContactsService.loadContacts();
    setState(() => _contacts = contacts);
  }

  Future<void> _shareContacts() async {
    final jsonStr = ContactsService.exportContactsJson(_contacts);
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/contacts.json');
    await file.writeAsString(jsonStr);
    await SharePlus.instance.share(
      ShareParams(
        text: 'Customer Contacts',
        files: [XFile(file.path)],
        title: 'Share Contacts',
      ),
    );
  }

  Future<void> _uploadContacts() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.isNotEmpty) {
      String jsonStr = '';
      final file = result.files.single;
      if (file.bytes != null) {
        jsonStr = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        jsonStr = await File(file.path!).readAsString();
      }
      if (jsonStr.isNotEmpty) {
        final newContacts = ContactsService.importContactsJson(jsonStr);
        await ContactsService.mergeContacts(newContacts);
        await _load();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Contacts updated!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _uploadContacts,
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: _shareContacts),
        ],
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, i) {
          final c = _contacts[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.store,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              c['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if ((c['shopName'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4.0,
                              bottom: 2.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.storefront,
                                  size: 16,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    c['shopName'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if ((c['address'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 2.0,
                              bottom: 2.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    c['address'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if ((c['gstin'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 2.0,
                              bottom: 2.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.confirmation_number,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    c['gstin'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Delete Contact'),
                              content: Text(
                                'Are you sure you want to delete this contact?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        setState(() {
                          _contacts.removeAt(i);
                        });
                        await ContactsService.saveContacts(_contacts);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contact deleted.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
