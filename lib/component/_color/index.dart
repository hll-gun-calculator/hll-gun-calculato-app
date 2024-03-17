import 'package:flutter/material.dart';

class ColorWidget extends StatefulWidget {
  final Widget? child;
  final Color? initializeColor;
  final Function(Color color)? onEvent;

  const ColorWidget({
    super.key,
    this.child,
    this.initializeColor,
    this.onEvent,
  });

  @override
  State<ColorWidget> createState() => _ColorWidgetState();
}

class _ColorWidgetState extends State<ColorWidget> {
  List<Color> colors = [
    Colors.yellow,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.brown,
  ];

  ValueNotifier<Color> selectColor = ValueNotifier(Colors.transparent);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        if (widget.initializeColor != null) selectColor.value = widget.initializeColor!;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        color: selectColor.value,
        child: SizedBox(
          height: 50,
          width: 50,
          child: widget.child,
        ),
      ),
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          builder: (buildContext) {
            return StatefulBuilder(
              builder: (modalBuildContext, modalSetStatus) {
                return Scaffold(
                  appBar: AppBar(
                    leading: const CloseButton(),
                  ),
                  body: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    children: [
                      ...colors
                          .map((e) => GestureDetector(
                                child: Card(
                                  color: e,
                                  child: const SizedBox(height: 50, width: 50),
                                ),
                                onTap: () {
                                  modalSetStatus(() {
                                    selectColor.value = e;
                                  });
                                  Navigator.of(context).pop();
                                  widget.onEvent!(selectColor.value);
                                },
                              ))
                          .toList(),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
