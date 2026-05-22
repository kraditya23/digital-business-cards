import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_app/providers/user_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/services/cloud/cloudinary_storage_service.dart';
import 'package:card_app/utilities/constants.dart';
import 'package:card_app/widgets/snackbars.dart';

class LabeledField {
  String label;
  TextEditingController controller;

  LabeledField({required this.label, required this.controller});
}

class EditContactInfo extends ConsumerStatefulWidget {
  const EditContactInfo({super.key});

  @override
  ConsumerState<EditContactInfo> createState() => _EditContactInfoState();
}

class _EditContactInfoState extends ConsumerState<EditContactInfo> {
  File? _selectedCoverImage;
  File? _selectedProfilePicImage;
  late TextEditingController nameController;
  late TextEditingController jobTitleController;
  late TextEditingController organisationController;
  late TextEditingController locationController;
  late TextEditingController addressController;
  late List<LabeledField> phoneFields;
  late List<LabeledField> emailFields;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value;

    nameController = TextEditingController(text: user?.name ?? '');
    jobTitleController = TextEditingController(text: user?.jobTitle ?? '');
    organisationController = TextEditingController(
      text: user?.organisation ?? '',
    );
    locationController = TextEditingController(text: user?.location ?? '');
    addressController = TextEditingController(text: user?.address ?? '');

    final phoneList = user?.phoneNumbers;
    final emailList = user?.emails;

    phoneFields =
        (phoneList != null && phoneList.isNotEmpty)
            ? phoneList
                .map(
                  (p) => LabeledField(
                    label: 'mobile',
                    controller: TextEditingController(text: p),
                  ),
                )
                .toList()
            : [
              LabeledField(
                label: 'mobile',
                controller: TextEditingController(),
              ),
            ];

    emailFields =
        (emailList != null && emailList.isNotEmpty)
            ? emailList
                .map(
                  (e) => LabeledField(
                    label: 'home',
                    controller: TextEditingController(text: e),
                  ),
                )
                .toList()
            : [
              LabeledField(label: 'home', controller: TextEditingController()),
            ];
  }

  @override
  void dispose() {
    nameController.dispose();
    jobTitleController.dispose();
    organisationController.dispose();
    locationController.dispose();
    addressController.dispose();
    for (var field in phoneFields) {
      field.controller.dispose();
    }
    for (var field in emailFields) {
      field.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(bool isCover) async {
    final pickedfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedfile != null) {
      final imageFile = File(pickedfile.path);
      setState(() {
        if (isCover) {
          _selectedCoverImage = imageFile;
        } else {
          _selectedProfilePicImage = imageFile;
        }
      });
    }
  }

  void _showCupertinoLabelPicker(
    BuildContext context,
    List<String> options,
    String currentLabel,
    Function(String) onSelected,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            actions:
                options
                    .map(
                      (label) => CupertinoActionSheetAction(
                        onPressed: () {
                          onSelected(label);
                          Navigator.pop(context);
                        },
                        child: Text(label),
                      ),
                    )
                    .toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text('Edit Contact Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Cover + Profile Layout
            SizedBox(
              height: 180,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Cover Image
                  GestureDetector(
                    onTap: () => _pickImage(true),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              _selectedCoverImage != null
                                  ? FileImage(_selectedCoverImage!)
                                  : (user?.coverPicUrl?.isNotEmpty == true)
                                  ? NetworkImage(user!.coverPicUrl!)
                                  : AssetImage(defaultCover) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  // Profile Picture
                  Positioned(
                    bottom: -25,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(false),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 56,
                          backgroundImage:
                              _selectedProfilePicImage != null
                                  ? FileImage(_selectedProfilePicImage!)
                                  : (user?.profilePicUrl?.isNotEmpty == true)
                                  ? NetworkImage(user!.profilePicUrl!)
                                  : const AssetImage(defaultAvatar)
                                      as ImageProvider,
                          child: const Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(Icons.camera_alt, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: jobTitleController,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: organisationController,
              decoration: const InputDecoration(
                labelText: 'Organisation/Company',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    'Phone Numbers',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...phoneFields.map(
                    (field) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            color: CupertinoColors.systemGrey5,
                            onPressed: () {
                              _showCupertinoLabelPicker(
                                context,
                                ['mobile', 'home', 'work'],
                                field.label,
                                (val) => setState(() => field.label = val),
                              );
                            }, minimumSize: Size(30, 30),
                            child: Text(
                              field.label,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CupertinoTextField(
                              controller: field.controller,
                              placeholder: 'Phone',
                              keyboardType: TextInputType.phone,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() => phoneFields.remove(field));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        phoneFields.add(
                          LabeledField(
                            label: 'mobile',
                            controller: TextEditingController(),
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    label: const Text(
                      'Add phone',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    'Emails',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...emailFields.map(
                    (field) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            color: CupertinoColors.systemGrey5,
                            onPressed: () {
                              _showCupertinoLabelPicker(
                                context,
                                ['home', 'work'],
                                field.label,
                                (val) => setState(() => field.label = val),
                              );
                            }, minimumSize: Size(30, 30),
                            child: Text(
                              field.label,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CupertinoTextField(
                              controller: field.controller,
                              placeholder: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() => emailFields.remove(field));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        emailFields.add(
                          LabeledField(
                            label: 'home',
                            controller: TextEditingController(),
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    label: const Text(
                      'Add email',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 0, 11, 35),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 8,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.save),
                label: Text('Save Changes'),
                onPressed: () async {
                  final user = ref.read(userProvider).value;
                  if (user == null) return;

                  String profilePicUrl = user.profilePicUrl ?? '';
                  String coverPicUrl = user.coverPicUrl ?? '';

                  if (_selectedProfilePicImage != null) {
                    profilePicUrl = await CloudinaryStorageService()
                        .uploadProfilePic(
                          _selectedProfilePicImage!,
                          user.username,
                        );
                  }
                  if (_selectedCoverImage != null) {
                    coverPicUrl = await CloudinaryStorageService()
                        .uploadCoverPic(_selectedCoverImage!, user.username);
                  }

                  final phones =
                      phoneFields
                          .map((f) => f.controller.text.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                  final emails =
                      emailFields
                          .map((f) => f.controller.text.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                  await ref
                      .read(userProvider.notifier)
                      .updateContactInfo(
                        nameController.text.trim(),
                        profilePicUrl,
                        coverPicUrl,
                        jobTitleController.text.trim(),
                        organisationController.text.trim(),
                        locationController.text.trim(),
                        phones,
                        emails,
                      );

                  context.showSuccessSnackBar(
                    message: 'Profile updated successfully!',
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
