import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../data/index.dart';

/// 地图片
/// 按照资源来缓存与加载图片
class MapImageWidget extends StatefulWidget {
  final MapInfoAssets assets;
  final double width;
  final double height;

  const MapImageWidget({
    super.key,
    required this.assets,
    required this.width,
    required this.height,
  });

  @override
  State<MapImageWidget> createState() => _MapImageWidgetState();
}

class _MapImageWidgetState extends State<MapImageWidget> {
  RenderObjectWidget _loadStateWidget(ExtendedImageState state) {
    switch (state.extendedImageLoadState) {
      case LoadState.completed:
        return ExtendedRawImage(
          image: state.extendedImageInfo?.image,
        );
      case LoadState.loading:
        return const SizedBox();
      case LoadState.failed:
      default:
        return Center(
          child: Column(
            children: [
              const Text("未能加载地图"),
              Text(state.extendedImageLoadState.name),
            ],
          ),
        );
    }
  }

  Widget get _imageWidget {
    if (widget.assets.network != null && widget.assets.local == null) {
      return ExtendedImage.network(
        widget.assets.network!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        cache: true,
        loadStateChanged: _loadStateWidget,
      );
    } else if (widget.assets.network == null && widget.assets.local != null) {
      return ExtendedImage.asset(
        widget.assets.local!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        loadStateChanged: _loadStateWidget,
      );
    }

    return ExtendedImage(
      image: widget.assets.image!,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      enableMemoryCache: false,
      loadStateChanged: _loadStateWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _imageWidget;
  }
}
