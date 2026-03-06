import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadWidget extends StatefulWidget {
  final List<String> allowedExtensions;
  final int maxFiles;
  final Function(List<String> filePaths) onFilesSelected;
  final List<String>? existingFiles;

  const FileUploadWidget({
    super.key,
    this.allowedExtensions = const ['pdf', 'jpg', 'jpeg', 'png'],
    this.maxFiles = 5,
    required this.onFilesSelected,
    this.existingFiles,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  List<String> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingFiles != null) {
      _selectedFiles = List.from(widget.existingFiles!);
    }
  }

  Future<void> _pickFiles() async {
    if (_selectedFiles.length >= widget.maxFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${widget.maxFiles} files allowed'),
        ),
      );
      return;
    }

    final isImage = widget.allowedExtensions
        .any((ext) => ['jpg', 'jpeg', 'png'].contains(ext.toLowerCase()));

    if (isImage) {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _selectedFiles.add(image.path);
        });
        widget.onFilesSelected(_selectedFiles);
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFiles.add(result.files.single.path!);
        });
        widget.onFilesSelected(_selectedFiles);
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFilesSelected(_selectedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.upload_file),
          label: Text(
            'Upload Files (${_selectedFiles.length}/${widget.maxFiles})',
          ),
        ),
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_selectedFiles.length, (index) {
              final filePath = _selectedFiles[index];
              final fileName = filePath.split('/').last;
              return Chip(
                label: Text(
                  fileName.length > 20
                      ? '${fileName.substring(0, 20)}...'
                      : fileName,
                ),
                onDeleted: () => _removeFile(index),
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }),
          ),
        ],
      ],
    );
  }
}
