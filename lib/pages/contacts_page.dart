import 'dart:io';

import 'package:billing/general_utility.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../services/contacts_service.dart';
// import '../general_utility.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final formKey = GlobalKey<FormState>();
          final nameController = TextEditingController();
          final addressController = TextEditingController();
          final gstinController = TextEditingController();
          final width = MediaQuery.of(context).size.width * 0.95;
          final added = await showDialog<Map<String, String>>(
            context: context,
            builder:
                (context) => Dialog(
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 24,
                  ),
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add Contact',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  inputFormatters: [UpperCaseTextFormatter()],
                                  validator:
                                      (val) =>
                                          val == null || val.trim().isEmpty
                                              ? 'Enter Name'
                                              : null,
                                ),
                                TextFormField(
                                  controller: addressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Address',
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  inputFormatters: [UpperCaseTextFormatter()],
                                  minLines: 3,
                                  maxLines: 6,
                                ),
                                TextFormField(
                                  controller: gstinController,
                                  decoration: const InputDecoration(
                                    labelText: 'GSTIN',
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  inputFormatters: [UpperCaseTextFormatter()],
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return null;
                                    }
                                    final gstinRegex = RegExp(
                                      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}?$',
                                    );
                                    if (!gstinRegex.hasMatch(val.trim())) {
                                      return 'Enter valid GSTIN';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    Navigator.pop(context, {
                                      'name': nameController.text.trim(),
                                      'address': addressController.text.trim(),
                                      'gstin': gstinController.text.trim(),
                                    });
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          );
          if (added != null) {
            setState(() {
              _contacts.add(added);
            });
            await ContactsService.saveContacts(_contacts);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Contact added.')));
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Contact',
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, i) {
          final c = _contacts[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.12),
                    child: Icon(
                      Icons.store,
                      color: Theme.of(context).colorScheme.primary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if ((c['address'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4.0,
                              bottom: 2.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    c['address'] ?? '',
                                    style: const TextStyle(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if ((c['gstin'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4.0,
                              bottom: 2.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.confirmation_number,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    c['gstin'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 15,
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
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit',
                    onPressed: () async {
                      final edited = await showDialog<Map<String, String>>(
                        context: context,
                        builder: (context) {
                          final formKey = GlobalKey<FormState>();
                          final nameController = TextEditingController(
                            text: c['name'] ?? '',
                          );
                          final addressController = TextEditingController(
                            text: c['address'] ?? '',
                          );
                          final gstinController = TextEditingController(
                            text: c['gstin'] ?? '',
                          );
                          final width =
                              MediaQuery.of(context).size.width * 0.95;
                          return Dialog(
                            insetPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 24,
                            ),
                            child: Container(
                              width: width,
                              padding: const EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Edit Contact',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Form(
                                      key: formKey,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: nameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Name',
                                            ),
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            inputFormatters: [
                                              UpperCaseTextFormatter(),
                                            ],
                                            validator:
                                                (val) =>
                                                    val == null ||
                                                            val.trim().isEmpty
                                                        ? 'Enter Name'
                                                        : null,
                                          ),
                                          TextFormField(
                                            controller: addressController,
                                            decoration: const InputDecoration(
                                              labelText: 'Address',
                                            ),
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            inputFormatters: [
                                              UpperCaseTextFormatter(),
                                            ],
                                            minLines: 3,
                                            maxLines: 6,
                                          ),
                                          TextFormField(
                                            controller: gstinController,
                                            decoration: const InputDecoration(
                                              labelText: 'GSTIN',
                                            ),
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            inputFormatters: [
                                              UpperCaseTextFormatter(),
                                            ],
                                            validator: (val) {
                                              if (val == null ||
                                                  val.trim().isEmpty) {
                                                return null;
                                              }
                                              final gstinRegex = RegExp(
                                                r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}?$',
                                              );
                                              if (!gstinRegex.hasMatch(
                                                val.trim(),
                                              )) {
                                                return 'Enter valid GSTIN';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        const SizedBox(width: 12),
                                        TextButton(
                                          onPressed: () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              Navigator.pop(context, {
                                                'name':
                                                    nameController.text.trim(),
                                                'address':
                                                    addressController.text
                                                        .trim(),
                                                'gstin':
                                                    gstinController.text.trim(),
                                              });
                                            }
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                      if (edited != null) {
                        setState(() {
                          _contacts[i] = edited;
                        });
                        await ContactsService.saveContacts(_contacts);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contact updated.')),
                        );
                      }
                    },
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
                              content: const Text(
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
