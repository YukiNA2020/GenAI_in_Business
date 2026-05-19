import 'package:collection_journey_app/app.dart';
import 'package:collection_journey_app/features/collection_browse/providers/collection_list_provider.dart';
import 'package:collection_journey_app/features/collection_browse/services/collection_query_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Collectory handoff shell shows Home tab and museum hall', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backendReachableProvider.overrideWith((ref) async => true),
          categoriesProvider.overrideWith((ref) async => <CategoryOption>[]),
          allTagsProvider.overrideWith((ref) async => <String>[]),
          userStatsProvider.overrideWith(
            (ref) async => const UserStats(
              totalCollections: 0,
              categoryCount: 0,
              publicCollections: 0,
              recentCollections: [],
            ),
          ),
          collectionListProvider.overrideWith((ref) {
            return CollectionListNotifier(
              ref.watch(collectionQueryServiceProvider),
            );
          }),
        ],
        child: const CollectoryApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('PERSONAL MUSEUM'), findsOneWidget);
    expect(find.text('Museum hall'), findsOneWidget);
    expect(find.text('Gallery'), findsWidgets);
    expect(find.text('Open room'), findsOneWidget);
  });
}
