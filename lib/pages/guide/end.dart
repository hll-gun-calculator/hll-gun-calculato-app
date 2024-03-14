import 'package:flutter/material.dart';

class GuideEnd extends StatefulWidget {
  const GuideEnd({super.key});

  @override
  State<GuideEnd> createState() => _GuideEndState();
}

class _GuideEndState extends State<GuideEnd> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.done_all,
            size: 65,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            "💐恭喜初步了解并设置你喜欢选项",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 5),
          const Text("点击’完成‘，结束引导，再见")
        ],
      ),
    );
  }
}
