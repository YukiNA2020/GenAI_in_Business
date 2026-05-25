import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'core/theme/collectory_theme.dart';
import 'features/collection_browse/services/collection_query_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await CollectoryColors.loadFromDesignExport();
  final apiOk = await ApiClient()
      .checkHealth()
      .timeout(const Duration(seconds: 5), onTimeout: () => false);
  if (!apiOk) {
    debugPrint(
      'Collectory: GET /api/health failed — start backend (cd backend && npm run dev) '
      'so Flutter can read SQLite via API.',
    );
  }
  runApp(
    const ProviderScope(
      child: CollectoryApp(),
    ),
  );
}
