// 负责人：成员 E / 成员 5 — 阶段四：正式 tag input
// INTEGRATION_IMPLEMENTATION_PATH.md §7.3 — AI tags 写入此组件，不再仅 SnackBar

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';

/// 可编辑的 tag chips 输入。AI tags 通过 [onTagsMerged] 注入。
class TagInputField extends StatefulWidget {
  const TagInputField({
    super.key,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
    this.onTagsMerged,
    this.maxTags = 10,
  });

  final List<String> tags;
  final ValueChanged<String> onAddTag;
  final ValueChanged<String> onRemoveTag;
  final ValueChanged<List<String>>? onTagsMerged;
  final int maxTags;

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (widget.tags.length >= widget.maxTags) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum ${widget.maxTags} tags allowed')),
      );
      return;
    }
    widget.onAddTag(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = widget.tags.length < widget.maxTags;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.tags.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => widget.onRemoveTag(tag),
                  backgroundColor: CollectoryColors.bgSecondary,
                  side: const BorderSide(color: CollectoryColors.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ),
        if (canAdd)
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: widget.tags.isEmpty
                  ? 'Type a tag and press enter'
                  : 'Add another tag…',
              hintStyle: CollectoryHandoffHeader.bodySecondary()
                  .copyWith(fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFFAF8F5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CollectoryColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CollectoryColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CollectoryColors.borderDark),
              ),
              suffixIcon: widget.tags.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: _submit,
                    )
                  : null,
            ),
            onSubmitted: (_) => _submit(),
            textInputAction: TextInputAction.done,
          ),
        if (!canAdd)
          Text(
            'Maximum ${widget.maxTags} tags reached',
            style: CollectoryHandoffHeader.bodySecondary()
                .copyWith(fontSize: 11),
          ),
      ],
    );
  }
}
