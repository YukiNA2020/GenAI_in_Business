// 负责人：成员 E / 成员 5
// 供成员 B 创建/编辑收藏表单接入 — 见 member_B/docs/Phase2_Task5_AI_Panel_by_Member_E.md

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';
import '../models/ai_form_payload.dart';
import '../services/ai_suggestion_service.dart';
import '../utils/ai_category_mapping.dart';

/// AI 建议面板：各按钮独立 loading；失败仅 SnackBar，不阻塞表单。
class AiSuggestionPanel extends ConsumerStatefulWidget {
  const AiSuggestionPanel({
    super.key,
    required this.buildPayload,
    required this.onTitleSelected,
    required this.onCategoryTagSelected,
    required this.onTagsSuggested,
    required this.onStoryApplied,
  });

  final AiFormPayload Function() buildPayload;
  final ValueChanged<String> onTitleSelected;
  final ValueChanged<String> onCategoryTagSelected;
  final ValueChanged<List<String>> onTagsSuggested;
  final ValueChanged<String> onStoryApplied;

  @override
  ConsumerState<AiSuggestionPanel> createState() => _AiSuggestionPanelState();
}

class _AiSuggestionPanelState extends ConsumerState<AiSuggestionPanel> {
  bool _loadingTitle = false;
  bool _loadingCategory = false;
  bool _loadingTags = false;
  bool _loadingStory = false;
  List<String> _titleSuggestions = const [];

  bool _ensureDescription(BuildContext context) {
    final desc = widget.buildPayload().description.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add a short story note first — AI needs a description.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  void _showAiError(BuildContext context, Object error) {
    final message = error is AiSuggestionException
        ? error.message
        : 'AI suggestion failed. You can still save manually.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _runTitle() async {
    if (!_ensureDescription(context)) return;
    setState(() {
      _loadingTitle = true;
      _titleSuggestions = const [];
    });
    try {
      final list = await ref
          .read(aiSuggestionServiceProvider)
          .suggestTitle(widget.buildPayload());
      if (!mounted) return;
      setState(() => _titleSuggestions = list);
      if (list.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No title suggestions returned.')),
        );
      }
    } catch (e) {
      if (mounted) _showAiError(context, e);
    } finally {
      if (mounted) setState(() => _loadingTitle = false);
    }
  }

  Future<void> _runCategory() async {
    if (!_ensureDescription(context)) return;
    setState(() => _loadingCategory = true);
    try {
      final result = await ref
          .read(aiSuggestionServiceProvider)
          .suggestCategory(widget.buildPayload());
      if (!mounted) return;
      final tag = tagLabelForAiCategory(result.category);
      if (tag == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category: ${result.category} (map tag manually)')),
        );
      } else {
        widget.onCategoryTagSelected(tag);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category applied: $tag')),
        );
      }
    } catch (e) {
      if (mounted) _showAiError(context, e);
    } finally {
      if (mounted) setState(() => _loadingCategory = false);
    }
  }

  Future<void> _runTags() async {
    if (!_ensureDescription(context)) return;
    setState(() => _loadingTags = true);
    try {
      final tags = await ref
          .read(aiSuggestionServiceProvider)
          .suggestTags(widget.buildPayload());
      if (!mounted) return;
      widget.onTagsSuggested(tags);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suggested tags: ${tags.join(', ')}')),
      );
    } catch (e) {
      if (mounted) _showAiError(context, e);
    } finally {
      if (mounted) setState(() => _loadingTags = false);
    }
  }

  Future<void> _runStory() async {
    if (!_ensureDescription(context)) return;
    setState(() => _loadingStory = true);
    try {
      final story = await ref
          .read(aiSuggestionServiceProvider)
          .generateStory(widget.buildPayload());
      if (!mounted) return;
      widget.onStoryApplied(story);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story draft applied — you can edit it.')),
      );
    } catch (e) {
      if (mounted) _showAiError(context, e);
    } finally {
      if (mounted) setState(() => _loadingStory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2EC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CollectoryColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('AI SUGGESTIONS', style: CollectoryHandoffHeader.metaLabel()),
              const SizedBox(width: 6),
              Text(
                '(Member E)',
                style: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _AiActionChip(
                label: _loadingTitle ? 'Titles…' : 'Titles',
                onPressed: _loadingTitle ? null : _runTitle,
              ),
              _AiActionChip(
                label: _loadingCategory ? 'Category…' : 'Category',
                onPressed: _loadingCategory ? null : _runCategory,
              ),
              _AiActionChip(
                label: _loadingTags ? 'Tags…' : 'Tags',
                onPressed: _loadingTags ? null : _runTags,
              ),
              _AiActionChip(
                label: _loadingStory ? 'Story…' : 'Story',
                onPressed: _loadingStory ? null : _runStory,
              ),
            ],
          ),
          if (_titleSuggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Pick a title',
              style: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 11),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _titleSuggestions.map((t) {
                return ActionChip(
                  label: Text(
                    t,
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  onPressed: () => widget.onTitleSelected(t),
                  backgroundColor: CollectoryColors.bgSecondary,
                  side: const BorderSide(color: CollectoryColors.borderLight),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _AiActionChip extends StatelessWidget {
  const _AiActionChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: const Size(0, 28),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: const BorderSide(color: CollectoryColors.borderDark),
        foregroundColor: CollectoryColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
