import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hll_gun_calculator/widgets/wave_border.dart';

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
  BoxFit fit = BoxFit.contain;

  RenderObjectWidget _loadStateWidget(ExtendedImageState state) {
    switch (state.extendedImageLoadState) {
      case LoadState.completed:
        return ExtendedRawImage(
          image: state.extendedImageInfo?.image,
          fit: fit,
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
    if (widget.assets.network!.isNotEmpty && widget.assets.local!.isEmpty) {
      return ExtendedImage.network(
        widget.assets.network!,
        width: widget.width,
        height: widget.height,
        fit: fit,
        cache: true,
        loadStateChanged: _loadStateWidget,
      );
    } else if (widget.assets.network!.isEmpty && widget.assets.local!.isNotEmpty) {
      return ExtendedImage.asset(
        widget.assets.local!,
        width: widget.width,
        height: widget.height,
        fit: fit,
        loadStateChanged: _loadStateWidget,
      );
    }

    return ExtendedImage(
      image: widget.assets.image!,
      width: widget.width,
      height: widget.height,
      fit: fit,
      filterQuality: FilterQuality.high,
      loadStateChanged: _loadStateWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _imageWidget;
  }
}

/// 预制火炮标记图标
/// 配置表加载
class MapPrefabricateGunMarkersIcon extends StatefulWidget {
  final Color? color;
  final double? opacity;
  final Function? onPressed;
  final bool isShowUpIcon;

  const MapPrefabricateGunMarkersIcon({
    super.key,
    this.color = const Color(0xff6787c4),
    this.opacity = .9,
    this.onPressed,
    this.isShowUpIcon = true,
  });

  @override
  State<MapPrefabricateGunMarkersIcon> createState() => _MapPrefabricateGunMarkersIconState();
}

class _MapPrefabricateGunMarkersIconState extends State<MapPrefabricateGunMarkersIcon> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      pressedOpacity: .8,
      padding: EdgeInsets.zero,
      onPressed: () => widget.onPressed!(),
      child: Transform.translate(
        offset: const Offset(0, -32),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 450),
              opacity: widget.isShowUpIcon ? 1 : 0,
              child: MapImageBaseWidget(
                backgroundColor: widget.color!.withOpacity(widget.opacity!),
                child: Container(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 15),
                  child: Image.asset(
                    MapIconType.PresupposeArty.path!,
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
            ),
            if (widget.isShowUpIcon)
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: MapIconPoint(
                  color: Color.lerp(widget.color, Theme.of(context).colorScheme.primary, .7),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: WaveBorder(
                  width: 2,
                  maxWidth: 30,
                  count: 3,
                  child: MapIconPoint(color: Color.lerp(widget.color, Theme.of(context).colorScheme.primary, .5)),
                ),
              )
          ],
        ),
      ),
    );
  }
}

/// 火炮标记图标
/// 用户创建
class MapGunMarkersIcon extends StatefulWidget {
  final String? resultNumber;
  final Color? headerColor;
  final Color? color;
  final double? opacity;
  final Function? onPressed;

  const MapGunMarkersIcon({
    super.key,
    this.resultNumber = "0000",
    this.headerColor = const Color(0xffffd27c),
    this.color = const Color(0xffe5b452),
    this.opacity = .9,
    this.onPressed,
  });

  @override
  State<MapGunMarkersIcon> createState() => _MapGunMarkersIconState();
}

class _MapGunMarkersIconState extends State<MapGunMarkersIcon> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      pressedOpacity: .8,
      padding: EdgeInsets.zero,
      onPressed: () => widget.onPressed!(),
      child: Transform.translate(
        offset: const Offset(0, -39),
        child: Wrap(
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            MapImageBaseWidget(
              backgroundColor: widget.color!.withOpacity(widget.opacity!),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Container(
                      color: widget.headerColor,
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Center(
                        child: Text(
                          widget.resultNumber ?? "0",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                        ),
                      ),
                    ),
                    Image.asset(
                      MapIconType.Arty.path!,
                      width: 18,
                      height: 18,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: WaveBorder(
                width: 2,
                maxWidth: 30,
                count: 3,
                child: MapIconPoint(color: Color.lerp(widget.color, Theme.of(context).colorScheme.primary, .5)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// 地图图标背景形状
class MapIconBackgroundShape extends CustomPainter {
  final Color backgroundColor;

  MapIconBackgroundShape({
    this.backgroundColor = Colors.black12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    const double radius = 3.0;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.75);
    final rRect = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(radius),
      topRight: const Radius.circular(radius),
    );

    var path = Path()
      ..moveTo(0, 0)
      ..addRRect(rRect)
      ..lineTo(size.width, size.height * 0.75)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height * 0.75)
      ..close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.9), 3.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MapImageBaseWidget extends StatelessWidget {
  final Color backgroundColor;
  final Widget? child;

  const MapImageBaseWidget({
    super.key,
    required this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MapIconBackgroundShape(
        backgroundColor: backgroundColor,
      ),
      isComplex: true,
      willChange: true,
      child: child,
    );
  }
}

/// 地图图标点
class MapIconPoint extends StatelessWidget {
  final Color? color;

  MapIconPoint({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 5,
        height: 5,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
