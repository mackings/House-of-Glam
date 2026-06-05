import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RichMediaViewer extends StatefulWidget {
  final Map<String, dynamic> listing;

  const RichMediaViewer({super.key, required this.listing});

  @override
  State<RichMediaViewer> createState() => _RichMediaViewerState();
}

class _RichMediaViewerState extends State<RichMediaViewer> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final items = _mediaItems(widget.listing);
    final title =
        widget.listing['title']?.toString() ??
        widget.listing['name']?.toString() ??
        widget.listing['clothPublished']?.toString() ??
        'Media preview';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      body:
          items.isEmpty
              ? const Center(child: CustomText('No media available.'))
              : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      itemCount: items.length,
                      onPageChanged: (index) {
                        setState(() => _activeIndex = index);
                      },
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child:
                              item.isVideo
                                  ? _VideoPreview(url: item.url)
                                  : _ZoomableImage(url: item.url),
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 116,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final selected = index == _activeIndex;
                          return InkWell(
                            onTap: () => setState(() => _activeIndex = index),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 96,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    selected
                                        ? AppColors.accentSoft
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      selected
                                          ? AppColors.accent
                                          : AppColors.border,
                                ),
                              ),
                              child:
                                  item.isVideo
                                      ? const Center(
                                        child: Icon(
                                          Icons.play_circle_outline_rounded,
                                          color: AppColors.accent,
                                          size: 32,
                                        ),
                                      )
                                      : ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          item.url,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => const Icon(
                                                Icons.broken_image_outlined,
                                                color: AppColors.subtext,
                                              ),
                                        ),
                                      ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemCount: items.length,
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _ZoomableImage extends StatelessWidget {
  final String url;

  const _ZoomableImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        color: Colors.black,
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => const CustomText(
                    'Unable to load image',
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  final String url;

  const _VideoPreview({required this.url});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadHtmlString(_videoHtml(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: WebViewWidget(controller: _controller),
    );
  }

  String _videoHtml(String url) {
    return '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body { margin: 0; height: 100%; background: #000; }
    video { width: 100%; height: 100%; object-fit: contain; background: #000; }
  </style>
</head>
<body>
  <video src="$url" controls playsinline></video>
</body>
</html>
''';
  }
}

class _MediaItem {
  final String url;
  final bool isVideo;

  const _MediaItem({required this.url, required this.isVideo});
}

List<_MediaItem> _mediaItems(Map<String, dynamic> listing) {
  final items = <_MediaItem>[];

  void addImages(dynamic value) {
    if (value is List) {
      for (final item in value) {
        final url = item?.toString().trim();
        if (url != null && url.isNotEmpty) {
          items.add(_MediaItem(url: url, isVideo: false));
        }
      }
    }
  }

  void addVideos(dynamic value) {
    if (value is List) {
      for (final item in value) {
        final url = item?.toString().trim();
        if (url != null && url.isNotEmpty) {
          items.add(_MediaItem(url: url, isVideo: true));
        }
      }
    }
  }

  addImages(listing['images']);
  final media = listing['media'];
  if (media is Map) {
    addImages(media['zoomImages']);
    addImages(media['fabricCloseups']);
    addImages(media['beforeAfterShowcases']);
    addImages(media['styledLookPreviews']);
    addVideos(media['videoPreviews']);
  }

  return items;
}
