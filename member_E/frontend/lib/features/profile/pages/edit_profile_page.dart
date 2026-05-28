// 负责人：成员 E / 成员 5 — EditProfilePage（阶段三·任务 3）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';
import '../../collection_browse/widgets/design/collectory_favorite_tags.dart';
import '../providers/profile_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  TextEditingController? _nameController;
  TextEditingController? _bioController;
  TextEditingController? _avatarController;
  final Set<String> _prefs = {};
  bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) return;
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.displayName);
    _bioController = TextEditingController(text: profile.bio);
    _avatarController = TextEditingController(text: profile.avatarUrl ?? '');
    _prefs.addAll(profile.collectionPreferences);
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _bioController?.dispose();
    _avatarController?.dispose();
    super.dispose();
  }

  void _save() {
    _ensureInitialized();
    ref.read(userProfileProvider.notifier).updateProfile(
          displayName: _nameController!.text.trim(),
          bio: _bioController!.text.trim(),
          avatarUrl: _avatarController!.text.trim().isEmpty
              ? null
              : _avatarController!.text.trim(),
          collectionPreferences: _prefs.toList(),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved locally (mock).')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized();
    return Scaffold(
      backgroundColor: CollectoryColors.bgApp,
      appBar: AppBar(
        title: const Text('Edit profile'),
        backgroundColor: CollectoryColors.bgApp,
        foregroundColor: CollectoryColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(CollectoryColors.screenPadding),
        children: [
          Text('Display name', style: CollectoryHandoffHeader.metaLabel()),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController!,
            decoration: const InputDecoration(
              hintText: 'Nickname',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Avatar URL', style: CollectoryHandoffHeader.metaLabel()),
          const SizedBox(height: 6),
          TextField(
            controller: _avatarController!,
            decoration: const InputDecoration(
              hintText: 'https://… or /uploads/avatars/…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Bio', style: CollectoryHandoffHeader.metaLabel()),
          const SizedBox(height: 6),
          TextField(
            controller: _bioController!,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'A short curator bio',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Collection preferences', style: CollectoryHandoffHeader.metaLabel()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: CollectoryFavoriteTags.labels.map((tag) {
              final selected = _prefs.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _prefs.add(tag);
                    } else {
                      _prefs.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: CollectoryColors.btnPrimaryBg,
              foregroundColor: CollectoryColors.btnPrimaryText,
            ),
            child: Text(
              'Save profile',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
