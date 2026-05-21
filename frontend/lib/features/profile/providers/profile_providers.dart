// 负责人：成员 E / 成员 5

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';

/// 本地 mock 用户资料（阶段三无 PUT /api/users，编辑后仅存内存）。
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile.demo());

  void updateProfile({
    String? displayName,
    String? avatarUrl,
    String? bio,
    List<String>? collectionPreferences,
  }) {
    state = state.copyWith(
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      collectionPreferences: collectionPreferences,
    );
  }
}

/// Mock 登录态（阶段三占位，后续可接 JWT）。
final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, AuthSession>((ref) {
  return AuthSessionNotifier();
});

class AuthSessionNotifier extends StateNotifier<AuthSession> {
  AuthSessionNotifier()
      : super(const AuthSession(
          isLoggedIn: true,
          email: 'demo@collection-journey.app',
        ));

  void signIn({required String email}) {
    state = AuthSession(isLoggedIn: true, email: email.trim());
  }

  void signOut() {
    state = AuthSession.guest;
  }

  void register({required String email}) {
    state = AuthSession(isLoggedIn: true, email: email.trim());
  }
}
