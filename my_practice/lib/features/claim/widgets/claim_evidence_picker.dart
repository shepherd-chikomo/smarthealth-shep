import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_practice/domain/models/claim_models.dart';

class ClaimEvidencePicker extends StatelessWidget {
  const ClaimEvidencePicker({
    super.key,
    required this.files,
    required this.onChanged,
  });

  final List<ClaimEvidenceFile> files;
  final ValueChanged<List<ClaimEvidenceFile>> onChanged;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    if (result == null) return;

    final next = [...files];
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) continue;
      final mime = _mimeForExtension(file.extension);
      final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
      next.add(
        ClaimEvidenceFile(
          name: file.name,
          type: mime,
          size: bytes.length,
          dataUrl: dataUrl,
        ),
      );
    }
    onChanged(next);
  }

  String _mimeForExtension(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.upload_file),
          label: const Text('Add documents'),
        ),
        const SizedBox(height: 8),
        Text(
          'Business registration, practice license, MDPCZ certificate, or authorization letter.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...files.map(
            (f) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${(f.size / 1024).toStringAsFixed(1)} KB'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  onChanged(files.where((x) => x.name != f.name).toList());
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
