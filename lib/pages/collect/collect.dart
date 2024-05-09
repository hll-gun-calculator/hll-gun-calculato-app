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

  bool isSelectAll = false;

  List<String> selectList = [];

  /// 删除选择的收藏
  void deleteSelectCollect(CollectProvider collectData) {
    for (var id in selectList) {
      collectData.deleteAsId(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectProvider>(
      builder: (BuildContext context, CollectProvider collectData, Widget? widget) {
        return Scaffold(
          appBar: AppBar(
            title: Text(FlutterI18n.translate(context, "collect.title")),
            actions: [
              if (collectData.list.isNotEmpty && !isEdit)
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
          body: Column(
            children: [
              Expanded(
                child: collectData.list.isNotEmpty
                    ? ListView(
                        children: collectData
                            .sort()
                            .list
                            .map(
                              (i) => CollectCalcCard(
                                i: i,
                                leading: isEdit
                                    ? ClipRRect(
                                        clipBehavior: Clip.none,
                                        child: Checkbox(
                                          value: selectList.contains(i.id),
                                          onChanged: (v) {
                                            setState(() {
                                              if (selectList.where((id) => id == i.id).isNotEmpty) {
                                                selectList.removeWhere((tId) => tId == i.id);
                                              } else {
                                                selectList.add(i.id.toString());
                                              }

                                              if (selectList.length != collectData.list.length) {
                                                isSelectAll = false;
                                              }
                                            });
                                          },
                                        ),
                                      )
                                    : null,
                              ),
                            )
                            .toList(),
                      )
                    : const Center(
                        child: EmptyWidget(),
                      ),
              ),
              if (isEdit)
                Row(
                  children: [
                    Checkbox(
                      value: isSelectAll || selectList.length == collectData.list.length,
                      onChanged: (v) {
                        setState(() {
                          (v as bool) ? selectList.addAll(collectData.list.map((e) => e.id).toList()) : selectList = [];
                          isSelectAll = !isSelectAll;
                        });
                      },
                    ),
                    IconButton(
                      onPressed: () => deleteSelectCollect(collectData),
                      icon: const Icon(Icons.delete),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() {
                        isEdit = !isEdit;
                      }),
                      child: Text(FlutterI18n.translate(context, "basic.button.complete")),
                    )
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
