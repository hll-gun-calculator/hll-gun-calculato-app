import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../data/index.dart';
import '../utils/index.dart';

class MapCardWidget extends StatefulWidget {
  final MapInfo i;
  final String selected;
  final Function()? onTap;

  const MapCardWidget({
    super.key,
    required this.i,
    this.selected = "",
    this.onTap,
  });

  @override
  State<MapCardWidget> createState() => _MapCardWidgetState();
}

class _MapCardWidgetState extends State<MapCardWidget> {
  I18nUtil i18nUtil = I18nUtil();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: SizedBox(
            width: 100,
            height: 70,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(3)),
              child: ExtendedImage.network(
                widget.i.assets!.network!,
                fit: BoxFit.cover,
                cache: true,
                cacheWidth: 100,
                cacheHeight: 70,
              ),
            ),
          ),
          title: Text(i18nUtil.as(context, widget.i.name)),
          subtitle: Text("${widget.i.size.dx} x ${widget.i.size.dy} | marker:${widget.i.marker!.length}"),
          trailing: widget.i.name == widget.selected ? const Icon(Icons.radio_button_checked) : const SizedBox(),
          selected: widget.onTap != null ? widget.i.name == widget.selected : false,
          onTap: widget.onTap,
        ),
      ],
    );
  }
}
