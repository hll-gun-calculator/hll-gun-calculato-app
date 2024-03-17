import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

class EmptyWidget extends StatelessWidget {
  final bool isChenkNetork;

  const EmptyWidget({
    Key? key,
    this.isChenkNetork = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context, appInfo, Widget? child) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Opacity(
              opacity: .2,
              child: Icon(Icons.line_style_rounded, size: 80),
            ),
            Opacity(
              opacity: .8,
              child: Text(FlutterI18n.translate(context, "basic.tip.notContent")),
            )
          ],
        ),
      );
    });
  }
}
