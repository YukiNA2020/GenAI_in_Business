import 'package:collection_journey_app/features/collection_browse/models/collection_item.dart';
import 'package:collection_journey_app/features/collection_browse/models/collection_query_state.dart';
import 'package:collection_journey_app/features/collection_browse/models/collection_room.dart';
import 'package:collection_journey_app/features/collection_browse/providers/collection_list_provider.dart';
import 'package:collection_journey_app/features/collection_browse/services/collection_query_service.dart';
import 'package:collection_journey_app/features/collection_browse/widgets/design/collectory_favorite_tags.dart';
import 'package:collection_journey_app/features/collection_browse/widgets/profile_collection_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets(
    'ISSUE-06: Profile favorite tags ignore Gallery collection filters',
    (tester) async {
      const galleryOnlyItem = CollectionItem(
        id: 1,
        title: 'Gallery Vinyl Only',
        category: 'vinyl',
        visibility: 'private',
      );
      const profileTicketItem = CollectionItem(
        id: 2,
        title: 'Profile Ticket Stub',
        category: 'ticket',
        visibility: 'private',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(
              (ref) => _StaticCollectionListNotifier([galleryOnlyItem]),
            ),
            profileCollectionsProvider.overrideWith(
              (ref) async => const [profileTicketItem],
            ),
            categoriesProvider.overrideWith(
              (ref) async => const [
                CategoryOption(id: 'vinyl', name: 'Vinyl'),
                CategoryOption(id: 'ticket', name: 'Tickets'),
              ],
            ),
            roomsProvider.overrideWith(
              (ref) async => const [
                CollectionRoomSummary(
                  id: 1,
                  month: '2026-05',
                  label: 'May Room',
                  collectionCount: 1,
                ),
              ],
            ),
            userStatsProvider.overrideWith(
              (ref) async => const UserStats(
                totalCollections: 1,
                categoryCount: 1,
                publicCollections: 0,
                recentCollections: [],
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProfileCollectionPreview(
                  embeddedInMemberEProfile: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(CollectoryFavoriteTagChip, 'Ticket'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile Ticket Stub'), findsWidgets);
      expect(find.text('Gallery Vinyl Only'), findsNothing);
      expect(find.text('No exhibits in this category.'), findsNothing);
    },
  );
}

class _StaticCollectionListNotifier extends CollectionListNotifier {
  _StaticCollectionListNotifier(List<CollectionItem> items)
      : super(CollectionQueryService()) {
    state = CollectionListState(
      query: const CollectionQueryState(category: 'vinyl', pageSize: 6),
      items: items,
      total: items.length,
    );
  }
}
