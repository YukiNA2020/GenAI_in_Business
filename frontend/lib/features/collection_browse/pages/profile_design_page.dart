import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/pages/profile_page.dart';

/// Profile Tab — 成员 E 阶段三 ProfilePage（任务 1–4）；成员 C 的 rooms 从页内入口打开
class ProfileDesignPage extends ConsumerWidget {
  const ProfileDesignPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ProfilePage();
  }
}
