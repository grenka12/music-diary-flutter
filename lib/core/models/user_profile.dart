import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  const UserProfile({
    required this.email,
    required this.displayName,
    required this.avatarAsset,
  });

  final String email;
  final String displayName;
  final String avatarAsset;

  static const String defaultAvatar = 'assets/avatars/default_user.png';

  UserProfile copyWith({
    String? displayName,
    String? avatarAsset,
  }) {
    return UserProfile(
      email: email,
      displayName: displayName ?? this.displayName,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }

  factory UserProfile.fromFirebaseUser(User user) {
    final email = user.email ?? '';
    final displayName = (user.displayName == null || user.displayName!.isEmpty)
        ? email.split('@').first
        : user.displayName!;

    return UserProfile(
      email: email,
      displayName: displayName,
      avatarAsset: defaultAvatar,
    );
  }
}
