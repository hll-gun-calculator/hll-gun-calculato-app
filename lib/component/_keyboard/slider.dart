import 'package:flutter/material.dart';

import 'theme.dart';

class SliderKeyboaed extends StatefulWidget {
  final TextEditingController controller;
  final Function onSubmit;
  late KeyboardTheme theme;

  SliderKeyboaed({
    super.key,
    KeyboardTheme? theme,
    required this.onSubmit,
    required this.controller,
  }) : super() {
    this.theme = theme ?? KeyboardTheme();
  }

  @override
  State<SliderKeyboaed> createState() => _SliderKeyboaedState();
}

class _SliderKeyboaedState extends State<SliderKeyboaed> {
  double o = 500;
  double t = 50;
  double t_o = 50;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.theme.padding,
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Slider.adaptive(
            min: 100,
            max: 1600,
            value: o,
            label: "$o",
            thumbColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
            inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
            onChangeEnd: (v) {
              widget.controller.text = v.toString();
            },
            onChanged: (v) {
              setState(() {
                o = v;
              });
            },
          ),
          SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.controller.text = (double.parse(widget.controller.text) - 100).toString();
                  });
                },
                icon: Icon(Icons.add),
              ),
              Expanded(
                flex: 1,
                child: Slider(
                  min: 0,
                  max: 100,
                  divisions: 10,
                  value: t,
                  label: "$t",
                  thumbColor: Theme.of(context).colorScheme.primary,
                  activeColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
                  inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
                  onChangeEnd: (v) {
                    setState(() {
                      if (widget.controller.text.isNotEmpty) widget.controller.text = (double.parse(widget.controller.text) - v).toString();
                      t = t_o;
                    });
                  },
                  onChanged: (v) {
                    setState(() {
                      t = v;
                    });
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.controller.text = (double.parse(widget.controller.text) + 100).toString();
                  });
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
