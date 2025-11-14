// lib/features/setup/widgets/avatar_upload_field.dart
//
// Small wrapper around FileUploadField specifically for avatar images.

import 'package:flutter/material.dart';

import '../../../data/supabase/storage_repository.dart';
import 'file_upload_field.dart';

class AvatarUploadField extends StatelessWidget {
  const AvatarUploadField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final storage = StorageRepository();

    return FileUploadField(
      controller: controller,
      label: 'Avatar URL',
      hint: 'Click "Upload" to choose an image',
      buttonText: 'Upload avatar',
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
      // Just plug StorageRepository into the generic upload function
      onUpload: (bytes, fileName) =>
          storage.uploadAvatar(bytes: bytes, fileName: fileName),
    );
  }
}
