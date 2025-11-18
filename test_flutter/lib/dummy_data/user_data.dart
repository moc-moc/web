/// ダミーユーザーデータ
class DummyUser {
  final String name;
  final String userId;
  final String? avatarUrl;
  final int streakDays;
  final double totalFocusedHours;
  final String bio;

  const DummyUser({
    required this.name,
    required this.userId,
    this.avatarUrl,
    required this.streakDays,
    required this.totalFocusedHours,
    required this.bio,
  });
}

/// デフォルトのダミーユーザー
const dummyUser = DummyUser(
  name: 'Alex Doe',
  userId: '@alex_doe',
  avatarUrl: null, // プレースホルダーとしてnull
  streakDays: 65,
  totalFocusedHours: 300.0,
  bio: 'Focused on productivity and continuous improvement. 🎯',
);

/// 複数のダミーユーザー（フレンド機能用、将来実装）
const dummyUsers = [
  dummyUser,
  DummyUser(
    name: 'Sarah Chen',
    userId: '@sarah_chen',
    avatarUrl: null,
    streakDays: 42,
    totalFocusedHours: 180.0,
    bio: 'Medical student aiming for excellence. 📚',
  ),
  DummyUser(
    name: 'Mike Johnson',
    userId: '@mike_j',
    avatarUrl: null,
    streakDays: 28,
    totalFocusedHours: 120.0,
    bio: 'Software engineer learning new technologies. 💻',
  ),
];
