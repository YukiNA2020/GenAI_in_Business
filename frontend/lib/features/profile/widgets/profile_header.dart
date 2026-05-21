// 负责人：成员 E / 成员 5

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/services/collection_query_service.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';
import '../providers/profile_providers.dart';
import '../pages/edit_profile_page.dart';
import '../pages/login_placeholder_page.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final session = ref.watch(authSessionProvider);
    final avatarUrl = _resolveAvatarUrl(profile.avatarUrl);
    final initial = profile.displayName.isNotEmpty
        ? profile.displayName.substring(0, 1)
        : '?';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: CollectoryColors.bgSecondary,
          backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(
                  initial,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CollectoryColors.textPrimary,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: CollectoryColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                session.isLoggedIn
                    ? (session.email ?? profile.email)
                    : 'Guest — sign in to sync',
                style: CollectoryHandoffHeader.bodySecondary()
                    .copyWith(fontSize: 12),
              ),
              if (profile.bio.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  profile.bio,
                  style: CollectoryHandoffHeader.bodySecondary()
                      .copyWith(fontSize: 13, height: 1.35),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _profileOutlineButton(
                    label: 'Edit profile',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const EditProfilePage(),
                        ),
                      );
                    },
                  ),
                  if (!session.isLoggedIn)
                    _profileOutlineButton(
                      label: 'Sign in',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginPlaceholderPage(),
                          ),
                        );
                      },
                    )
                  else
                    _profileOutlineButton(
                      label: 'Sign out',
                      onPressed: () {
                        ref.read(authSessionProvider.notifier).signOut();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signed out (mock).')),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _profileOutlineButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(0, 32),
        foregroundColor: CollectoryColors.textPrimary,
        side: const BorderSide(color: CollectoryColors.borderDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: CollectoryColors.textPrimary,
        ),
      ),
    );
  }

  String? _resolveAvatarUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final trimmed = path.trim();
    if (trimmed.startsWith('http')) return trimmed;
    return '$apiBaseUrl$trimmed';
  }
}
