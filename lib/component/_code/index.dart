import 'dart:convert';

import 'package:flutter/material.dart';

class CodeConvertJsonView extends StatefulWidget {
  final dynamic data;

  const CodeConvertJsonView({
    super.key,
    required this.data,
  });

  @override
  State<CodeConvertJsonView> createState() => _CodeViewState();
}

class _CodeViewState extends State<CodeConvertJsonView> {
  FocusNode focusNode = FocusNode();

  dynamic primitiveContent = "";

  String showContent = "N/A";

  bool isFormatting = false;

  @override
  void initState() {
    primitiveContent = widget.data;
    showContent = const JsonEncoder.withIndent('  ').convert(primitiveContent);
    super.initState();
  }

  void _onFormattingSwitch() {
    setState(() {
      isFormatting = !isFormatting;
      focusNode.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectionArea(
          focusNode: focusNode,
          child: Text(
            isFormatting ? showContent : primitiveContent.toJson().toString(),
            maxLines: isFormatting ? null : 3,
            overflow: isFormatting ? TextOverflow.clip : TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          child: IconButton.outlined(
            padding: EdgeInsets.zero,
            visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
            onPressed: () => _onFormattingSwitch(),
            icon: Icon(isFormatting ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          ),
        )
      ],
    );
  }
}
