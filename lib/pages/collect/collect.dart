import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/widgets/collect_calc_card.dart';
import '/component/_empty/index.dart';
import '/provider/collect_provider.dart';

class CollectPage extends StatefulWidget {
  const CollectPage({super.key});

  @override
  State<CollectPage> createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  bool isEdit = false;

  bool selectAll = false;

  List<String> selectList = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectProvider>(
      builder: (BuildContext context, CollectProvider data, Widget? widget) {
        return Scaffold(
          appBar: AppBar(
            title: Text(FlutterI18n.translate(context, "collect.title")),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isEdit = !isEdit;
                  });
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          body: data.list.isNotEmpty
              ? ListView(
                  children: data
                      .sort()
                      .list
                      .map((i) => CollectCalcCard(
                            i: i,
                            leading: isEdit
                                ? Checkbox(
                                    value: selectList.contains(i.id),
                                    onChanged: (v) {
                                      setState(() {
                                        if (selectList.where((id) => id == i.id).isNotEmpty) {
                                          selectList.removeWhere((tId) => tId == i.id);
                                        } else {
                                          selectList.add(i.id.toString());
                                        }

                                        if (selectList.length != data.list.length) {
                                          selectAll = false;
                                        }
                                      });
                                    },
                                  )
                                : null,
                          ))
                      .toList(),
                )
              : const Center(
                  child: EmptyWidget(),
                ),
          bottomSheet: isEdit
              ? Row(
                  children: [
                    Checkbox(
                      value: selectAll || selectList.length == data.list.length,
                      onChanged: (v) {
                        setState(() {
                          (v as bool) ? selectList.addAll(data.list.map((e) => e.id).toList()) : selectList = [];
                          selectAll = !selectAll;
                        });
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        for (var id in selectList) {
                          data.deleteAsId(id);
                        }
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                )
              : Container(),
        );
      },
    );
  }
}
