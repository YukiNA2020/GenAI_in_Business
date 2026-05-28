// 负责人：成员 E / 成员 5

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.bio = '',
    this.collectionPreferences = const [],
  });

  final int userId;
  final String username;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String bio;
  final List<String> collectionPreferences;

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    String? bio,
    List<String>? collectionPreferences,
  }) {
    return UserProfile(
      userId: userId,
      username: username,
      displayName: displayName ?? this.displayName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      collectionPreferences:
          collectionPreferences ?? this.collectionPreferences,
    );
  }

  static UserProfile demo() {
    return const UserProfile(
      userId: 1,
      username: 'collector_demo',
      displayName: 'Collector Demo',
      email: 'demo@collection-journey.app',
      avatarUrl: null,
      bio: '热爱收藏生活中的每一个美好瞬间。矿石、唱片、票根、明信片——每件小物背后都有一段旅程。',
      collectionPreferences: ['Music', 'Travel', 'Minerals', 'Memory'],
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.isLoggedIn,
    this.email,
  });

  final bool isLoggedIn;
  final String? email;

  static const guest = AuthSession(isLoggedIn: false);
}
