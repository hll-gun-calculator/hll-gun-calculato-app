import 'package:flutter/material.dart';

class GuideStart extends StatefulWidget {
  const GuideStart({super.key});

  @override
  State<GuideStart> createState() => _GuideStartState();
}

class _GuideStartState extends State<GuideStart> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hail,
            size: 65,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            "差几步，完成应用设置 :D",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 5),
          const Text("跟随引导，完成选项来开始")
        ],
      ),
    );
  }
}
