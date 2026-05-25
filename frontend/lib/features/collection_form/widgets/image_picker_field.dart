// 负责人：成员 E / 成员 5 — 阶段四：正式图片选择器
// INTEGRATION_IMPLEMENTATION_PATH.md §7.5 — 图片上传失败不阻塞文本保存

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';
import '../../collection_browse/widgets/design/exhibit_illustrations.dart';

/// 图片选择器：选图后预览，支持清除。
class ImagePickerField extends StatelessWidget {
  const ImagePickerField({
    super.key,
    required this.imageBytes,
    required this.imageFilename,
    this.onImagePicked,
    this.onClearImage,
  });

  final List<int>? imageBytes;
  final String? imageFilename;
  final void Function({
    required List<int> bytes,
    required String filename,
    required String mimeType,
  })? onImagePicked;
  final VoidCallback? onClearImage;

  String _mimeTypeFromFilename(String name) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read image file')),
      );
      return;
    }
    final name = file.name.isNotEmpty ? file.name : 'photo.jpg';
    final mime = _mimeTypeFromFilename(name);
    onImagePicked?.call(bytes: bytes, filename: name, mimeType: mime);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null && imageBytes!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: CollectoryColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CollectoryColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasImage)
            Stack(
              children: [
                Image.memory(
                  Uint8List.fromList(imageBytes!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 180),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: onClearImage,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ExhibitIcon(kind: ExhibitIconKind.memory, size: 52),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add photo or scan',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: CollectoryColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Use camera or gallery. Photo upload is optional.',
                          style: CollectoryHandoffHeader.bodySecondary()
                              .copyWith(fontSize: 11, height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => _pickFile(context),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 30),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            backgroundColor: CollectoryColors.btnPrimaryBg,
                            foregroundColor: CollectoryColors.btnPrimaryText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Upload',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
