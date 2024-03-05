import 'package:flutter/cupertino.dart';
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
        child: I18nText("basic.tip.notContent"),
      );
    });
  }
}
