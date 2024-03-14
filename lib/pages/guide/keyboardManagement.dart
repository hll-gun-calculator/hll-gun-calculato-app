import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hll_gun_calculator/component/_keyboard/index.dart';

class GuideKeyboardManagement extends StatefulWidget {
  const GuideKeyboardManagement({super.key});

  @override
  State<GuideKeyboardManagement> createState() => _GuideKeyboardManagementState();
}

class _GuideKeyboardManagementState extends State<GuideKeyboardManagement> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const ListTile(
            title: Text(
              "键盘",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            subtitle: Text("对于计算输入，应用提供内置几款输入控制器,能在控制器左下角找到设置按钮切换，同时会记住你在对应位置选择键盘，在下次加载时保持"),
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
              ),
              children: KeyboardType.values.skipWhile((value) => value == KeyboardType.None).map((i) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Card(
                    child: Column(
                      children: [
                        SizedBox(
                          child: Image.asset("assets/images/keyboard/${i.name}.png"),
                          height: (MediaQuery.of(context).size.width / 3) ,
                        ),
                        Text(FlutterI18n.translate(context, "basic.keyboards.${i.name}")),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
