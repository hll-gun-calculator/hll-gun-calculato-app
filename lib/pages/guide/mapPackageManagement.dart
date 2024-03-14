import 'package:flutter/material.dart';

class GuideMapPackageManagement extends StatefulWidget {
  const GuideMapPackageManagement({super.key});

  @override
  State<GuideMapPackageManagement> createState() => _GuideMapPackageManagementState();
}

class _GuideMapPackageManagementState extends State<GuideMapPackageManagement> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ListTile(
          title: Text(
            "地图包",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          subtitle: Text("作为’地图测量‘所加载地图数据，这包含地图本身、额外图层、坐标"),
        ),
        ListTile(
          title: const Text("内置"),
          subtitle: const Text("当前选择"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
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
          subtitle: Text("我们陈列出一些社区提供’地图包‘选择"),
        ),
      ],
    );
  }
}
