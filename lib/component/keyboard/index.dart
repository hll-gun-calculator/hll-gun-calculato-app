import 'package:flutter/material.dart';

late OverlayEntry overlayEntry;

KeyboardWidget({
  required TextEditingController controller,
  required Function(OverlayEntry) initialization,
  required Function(String) onTap,
  Function? onCommit,
  GestureTapCallback? onDel,
}) {
  overlayEntry = OverlayEntry(builder: (context) {
    List<String> list = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      '',
    ];
    return Positioned(
        bottom: 0,
        child: Material(
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: List.generate(
                      list.length,
                          (int index) {
                        return Material(
                          color: Colors.white,
                          child: Ink(
                            color: Colors.white,
                            child: InkWell(
                              onTap: () {

                                if (index == 11) {
                                  onDel;
                                }
                                else {
                                  if (list[index] != "" && list[index] != "删除") {
                                    onTap(list[index]);
                                  }
                                }
                                // return index == 11
                                //     ? onDel
                                //     : () {
                                //         if (list[index] != "" &&
                                //             list[index] != "删除") {
                                //           onTap(list[index]);
                                //         }
                                //       };
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 0.25,
                                  ),
                                ),
                                alignment: Alignment.center,
                                height: 50,
                                // width: 100,
                                width: (MediaQuery.of(context).size.width) / 3,
                                child: Text(
                                  list[index],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Column(
                //   children: [
                //     SizedBox(
                //       width: 60,
                //       height: 50 * 1.5,
                //       child: MaterialButton(
                //         onPressed: onDel ?? () {},
                //         child: Text("删除", style: TextStyle(
                //             color: Colors.black, fontWeight: FontWeight.bold)),
                //         color: Colors.grey[100],
                //         elevation: 0,
                //         padding: EdgeInsets.all(0),),
                //     ),
                //     SizedBox(
                //       width: 60,
                //       height: 50 * 2.5,
                //       child: MaterialButton(
                //         onPressed: () {
                //           disKeypan();
                //           if (onCommit != null) onCommit();
                //         },
                //         child: Text("确认", style: TextStyle(
                //             color: Colors.white, fontWeight: FontWeight.bold),),
                //         color: Colors.blue,
                //         elevation: 0,
                //         padding: EdgeInsets.all(0),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ));
  });
  initialization(overlayEntry);
}

/// <summary>
/// todo: 保持光标在最后
/// author: zwb
/// date: 2021/7/19 11:43
/// param: 参数
/// return: void
/// <summary>
///
lastCursor({required TextEditingController textEditingController}) {
  /// 保持光标在最后
  final length = textEditingController.text.length;
  textEditingController.selection = TextSelection(baseOffset: length, extentOffset: length);
}

/// <summary>
/// todo: 自定义键盘的删除事件
/// author: zwb
/// date: 2021/7/19 11:45
/// param: 参数
/// return: void
/// <summary>
///
delCursor({required TextEditingController textEditingController}) {
  if (textEditingController.value.text != "") {
    textEditingController.text = textEditingController.text
        .substring(0, textEditingController.text.length - 1);
  }
}

/// <summary>
/// todo: 打开键盘
/// author: zwb
/// date: 2021/7/19 12:04
/// param: 参数
/// return: void
/// <summary>
///
openKeypan({required BuildContext context}) {
  Overlay.of(context).insert(overlayEntry);
}

/// <summary>
/// todo: 销毁键盘
/// author: zwb
/// date: 2021/7/19 12:03
/// param: 参数
/// return: void
/// <summary>
///
disKeypan() {
  overlayEntry.remove();
}

/// <summary>
/// todo: 数字键盘
/// author：zwb
/// dateTime：2021/7/19 10:25
/// filePath：lib/widgets/number_keypan.dart
/// desc: 示例
/// <summary>
// OverlayEntry overlayEntry;
// TextEditingController controller = TextEditingController();
//
// numberKeypan(
//   initialization: (v){
//     /// 初始化
//     overlayEntry = v;
//     /// 唤起键盘
//     openKeypan(context: context);
//   },
//   onDel: (){
//     delCursor(textEditingController: controller);
//   },
//   onTap: (v){
//     /// 更新输入框的值
//     controller.text += v;
//     /// 保持光标
//     lastCursor(textEditingController: controller);
//   },
// );
