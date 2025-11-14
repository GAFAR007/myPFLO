// lib/features/setup/widgets/file_upload_field.dart
//
// Generic, reusable "pick + upload file" component.
// Avatar, CV and any future uploads can all use this.

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Signature for a function that receives file bytes + name
/// and returns the public URL after upload.
typedef UploadFn = Future<String> Function(Uint8List bytes, String fileName);

class FileUploadField extends StatefulWidget {
  const FileUploadField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.buttonText,
    required this.allowedExtensions,
    required this.onUpload,
  });

  /// Controller that will hold the final public URL.
  final TextEditingController controller;

  /// Label above the text field (e.g. "Avatar URL", "CV URL").
  final String label;

  /// Hint text when the field is empty.
  final String hint;

  /// Text on the upload button (e.g. "Upload avatar").
  final String buttonText;

  /// Allowed file extensions for the picker.
  final List<String> allowedExtensions;

  /// Function that actually uploads the file and returns a URL.
  final UploadFn onUpload;

  @override
  State<FileUploadField> createState() => _FileUploadFieldState();
}

class _FileUploadFieldState extends State<FileUploadField> {
  bool _uploading = false;
  String? _error;

  /// Opens picker, calls the provided upload function, writes URL to controller.
  Future<void> _pickAndUpload() async {
    setState(() {
      _uploading = true;
      _error = null;
    });

    try {
      // 1) Let user select a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        withData: true, // important for web – we need bytes
      );

      // User pressed "Cancel"
      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final Uint8List? bytes = file.bytes;

      if (bytes == null) {
        throw Exception(
          'No bytes received from picker. (withData: true must be set.)',
        );
      }

      // 2) Delegate upload to the caller (avatar, CV, etc.)
      final url = await widget.onUpload(bytes, file.name);

      // 3) Save URL into text field
      widget.controller.text = url;

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ ${widget.label} uploaded')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Upload failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Read-only field showing the URL
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hint,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _uploading ? null : _pickAndUpload,
              icon: _uploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(_uploading ? 'Uploading...' : widget.buttonText),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 4),
          Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
