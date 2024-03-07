import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '/component/_empty/index.dart';
import '/provider/history_provider.dart';
import 'package:provider/provider.dart';

import '../../widgets/hisroy_calc_card.dart';

/// [计算历史]
/// 从状态机取出

class ComputingHistoryPage extends StatefulWidget {
  const ComputingHistoryPage({super.key});

  @override
  State<ComputingHistoryPage> createState() => _ComputingHistoryPageState();
}

class _ComputingHistoryPageState extends State<ComputingHistoryPage> {
  /// 清空会话历史
  void _cleanHistoryLog(HistoryProvider historyData) {
    historyData.clean();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(builder: (context, historyData, widget) {
      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "history.title")),
          actions: [
            if (historyData.list.isNotEmpty)
              IconButton(
                onPressed: () => _cleanHistoryLog(historyData),
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
        body: historyData.list.isNotEmpty
            ? ListView(
                children: historyData.sort().list.map((i) {
                  return HistoryCalcCard(
                    i: i,
                  );
                }).toList(),
              )
            : const Center(
                child: EmptyWidget(),
              ),
      );
    });
  }
}
