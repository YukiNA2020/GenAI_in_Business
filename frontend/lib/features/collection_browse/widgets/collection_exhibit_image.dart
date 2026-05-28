import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_item.dart';
import '../services/collection_query_service.dart';
import 'design/exhibit_illustrations.dart';

/// 从 API 的 `imageUrl` 加载图片；色块/占位上保留 Figma 风格浅色大字标题。
class CollectionExhibitImage extends StatefulWidget {
  const CollectionExhibitImage({
    super.key,
    required this.item,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.iconSize = 72,
    /// true：卡片上用首字大字；false：详情区用较短全名
    this.overlayInitialOnly = true,
  });

  final CollectionItem item;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double iconSize;
  final bool overlayInitialOnly;

  @override
  State<CollectionExhibitImage> createState() => _CollectionExhibitImageState();
}

class _CollectionExhibitImageState extends State<CollectionExhibitImage> {
  static final _imageDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.bytes,
      validateStatus: (code) => code != null && code >= 200 && code < 400,
    ),
  );

  Uint8List? _bytes;
  bool _loading = true;
  bool _failed = false;

  List<String> get _urls => collectionImageLoadUrls(
        collectionId: widget.item.id,
        imageUrl: widget.item.imageUrl,
      );

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CollectionExhibitImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.imageUrl != widget.item.imageUrl) {
      _bytes = null;
      _failed = false;
      _loading = true;
      _load();
    }
  }

  Future<void> _load() async {
    final urls = _urls;
    if (urls.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
      return;
    }

    for (final url in urls) {
      try {
        final response = await _imageDio.get<List<int>>(url);
        final data = response.data;
        if (data != null && data.length >= 100) {
          if (mounted) {
            setState(() {
              _bytes = Uint8List.fromList(data);
              _loading = false;
              _failed = false;
            });
          }
          return;
        }
      } catch (_) {
        // try next URL
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showTitleOverlay =
        widget.item.title.isNotEmpty && !_loading && (_failed || _bytes == null);
    return _clip(
      Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: _buildBackground()),
          if (showTitleOverlay)
            _TitleOverlay(
              title: widget.item.title,
              initialOnly: widget.overlayInitialOnly,
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (_loading) {
      return const ColoredBox(
        color: CollectoryColors.bgSecondary,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_failed || _bytes == null) {
      return _PlaceholderBackground(
        category: widget.item.category,
        iconSize: widget.iconSize,
      );
    }

    return Image.memory(
      _bytes!,
      fit: widget.fit,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => _PlaceholderBackground(
        category: widget.item.category,
        iconSize: widget.iconSize,
      ),
    );
  }

  Widget _clip(Widget child) {
    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }
    return child;
  }
}

class _PlaceholderBackground extends StatelessWidget {
  const _PlaceholderBackground({
    required this.category,
    required this.iconSize,
  });

  final String? category;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final kind =
        ExhibitIcon.fromCategory(category) ?? ExhibitIconKind.memory;
    return ColoredBox(
      color: categoryAccent(category),
      child: Center(child: ExhibitIcon(kind: kind, size: iconSize)),
    );
  }
}

/// 叠在图片上的浅色大字（原先占位卡片样式）
class _TitleOverlay extends StatelessWidget {
  const _TitleOverlay({
    required this.title,
    required this.initialOnly,
  });

  final String title;
  final bool initialOnly;

  @override
  Widget build(BuildContext context) {
    final text = initialOnly
        ? (title.characters.isNotEmpty ? title.characters.first : '?')
        : (title.length > 16 ? '${title.substring(0, 15)}…' : title);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: initialOnly ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: initialOnly ? 32 : 15,
            fontWeight: FontWeight.w700,
            height: 1.1,
            color: CollectoryColors.btnPrimaryText,
            shadows: const [
              Shadow(
                color: Color(0x66000000),
                offset: Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
