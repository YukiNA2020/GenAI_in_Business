import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/profile_collection_preview.dart';

/// Profile — 完整 Flutter 主页（API 数据），无 PNG 热区
class ProfileDesignPage extends ConsumerWidget {
  const ProfileDesignPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ProfileCollectionPreview();
  }
}
