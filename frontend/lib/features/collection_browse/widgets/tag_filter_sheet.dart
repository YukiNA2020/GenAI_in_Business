import 'package:flutter/material.dart';

import '../../../core/layout/collectory_mobile_shell.dart';
import '../../../core/theme/collectory_theme.dart';

/// Bottom inset so the sheet sits above [CollectoryBottomNav] + home indicator.
double tagFilterSheetBottomReserve(BuildContext context) {
  const nav = CollectoryColors.bottomNavHeight;
  final safe = MediaQuery.viewPaddingOf(context).bottom;
  if (safe > 0) return nav + safe;
  if (CollectoryMobileShell.usePhoneFrame) return nav + 34;
  return nav;
}

void showTagFilterSheet({
  required BuildContext context,
  required List<String> tags,
  required String? selectedTag,
  required ValueChanged<String?> onSelect,
}) {
  final sheetContext = context;
  final bottomReserve = tagFilterSheetBottomReserve(sheetContext);
  final viewportHeight = MediaQuery.sizeOf(sheetContext).height;
  final maxSheetHeight = (viewportHeight - bottomReserve - 72).clamp(
    220.0,
    viewportHeight * 0.58,
  );

  showModalBottomSheet<void>(
    context: sheetContext,
    isScrollControlled: true,
    useRootNavigator: false,
    useSafeArea: false,
    constraints: const BoxConstraints(
      maxWidth: CollectoryMobileShell.designWidth,
    ),
    backgroundColor: Colors.transparent,
    builder: (modalContext) {
      final pad = CollectoryColors.screenPadding;

      return Padding(
        padding: EdgeInsets.only(bottom: bottomReserve),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: CollectoryColors.bgCard,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: CollectoryMobileShell.designWidth,
                height: maxSheetHeight,
                child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 12, pad, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: CollectoryColors.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Filter by tag',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              label: const Text('All tags'),
                              onPressed: () {
                                onSelect(null);
                                Navigator.pop(modalContext);
                              },
                            ),
                            ...tags.map(
                              (tag) => FilterChip(
                                label: Text(tag),
                                selected: selectedTag == tag,
                                onSelected: (_) {
                                  onSelect(tag);
                                  Navigator.pop(modalContext);
                                },
                                showCheckmark: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    },
  );
}
