// lib/features/setup/widgets/cv_upload_field.dart
//
// Small wrapper around FileUploadField specifically for CVs.

import 'package:flutter/material.dart';

import '../../../data/supabase/storage_repository.dart';
import 'file_upload_field.dart';

class CvUploadField extends StatelessWidget {
  const CvUploadField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final storage = StorageRepository();

    return FileUploadField(
      controller: controller,
      label: 'CV URL',
      hint: 'Click "Upload" to choose your CV',
      buttonText: 'Upload CV',
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onUpload: (bytes, fileName) =>
          storage.uploadCv(bytes: bytes, fileName: fileName),
    );
  }
}
