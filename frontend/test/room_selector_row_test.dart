import 'package:collection_journey_app/features/collection_browse/models/collection_room.dart';
import 'package:collection_journey_app/features/collection_browse/widgets/design/room_selector_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RoomSelectorRow keeps long room labels on one line', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(240, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RoomSelectorRow(
            selectedRoomId: 1,
            rooms: [
              CollectionRoomSummary(
                id: 1,
                month: '2026-03',
                label: 'March Room',
              ),
              CollectionRoomSummary(
                id: 2,
                month: '2026-04',
                label: 'April Room',
              ),
              CollectionRoomSummary(
                id: 3,
                month: '2026-05',
                label: 'May Room',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final label = tester.widget<Text>(find.text('March Room'));
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
  });
}
