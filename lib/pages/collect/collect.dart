import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hll_emplacement_calculator/component/_empty/index.dart';
import 'package:hll_emplacement_calculator/provider/collect_provider.dart';
import 'package:provider/provider.dart';

import '../../widgets/collect_calc_card.dart';

class CollectPage extends StatefulWidget {
  const CollectPage({super.key});

  @override
  State<CollectPage> createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CollectProvider>(
      builder: (BuildContext context, CollectProvider data, Widget? widget) {
        return Scaffold(
          appBar: AppBar(
            title: Text(FlutterI18n.translate(context, "collect.title")),
          ),
          body: ListView(
            children: data.list.isNotEmpty ? data.list.map((i) => collectCalcCard(i: i)).toList() : [
              const Center(
                child: EmptyWidget(),
              ),
            ],
          ),
        );
      },
    );
  }
}
