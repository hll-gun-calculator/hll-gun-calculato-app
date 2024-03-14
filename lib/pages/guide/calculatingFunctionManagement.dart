import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hll_gun_calculator/provider/calc_provider.dart';
import 'package:provider/provider.dart';

import '../../constants/app.dart';

class GuideCalculatingFunctionManagement extends StatefulWidget {
  const GuideCalculatingFunctionManagement({super.key});

  @override
  State<GuideCalculatingFunctionManagement> createState() => _GuideCalculatingFunctionManagementState();
}

class _GuideCalculatingFunctionManagementState extends State<GuideCalculatingFunctionManagement> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CalcProvider>(builder: (context, calcData, widget) {
      return ListView(
        children: [
          const ListTile(
            title: Text(
              "计算函数",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            subtitle: Text("它是计算器的核心，负责对输入值比对各项参数最后求结果，同时你可以随时改用其他‘计算函数’，在内部提供阵营公式、变量、角度;如果允许你可以在应用内更新‘计算函数’."),
          ),
          ListTile(
            title: Text(calcData.currentCalculatingFunctionName),
            subtitle: const Text("当前选择"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              App.url.opEnPage(context, "/calculatingFunctionConfig");
            },
          ),
          const Divider(),
          Container(
            padding: EdgeInsets.only(left: 15),
            child: Row(
              children: [
                RawChip(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  label: Text("推荐"),
                  color: MaterialStatePropertyAll(Colors.blue.shade100),
                ),
              ],
            ),
          ),
          const ListTile(
            title: Text("来自第三方"),
            subtitle: Text("我们陈列出一些社区提供’计算函数‘选择"),
          ),
          ...[1, 2, 3].map((e) {
            return ListTile(
              title: Text("名称"),
              subtitle: Text("作者"),
              trailing: Wrap(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.downloading),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add_circle_outline),
                    label: Text("添加并作为默认"),
                  )
                ],
              ),
            );
          })
        ],
      );
    });
  }
}
