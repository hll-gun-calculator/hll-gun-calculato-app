import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/package_provider.dart';

class VersionPage extends StatefulWidget {
  const VersionPage({super.key});

  @override
  State<VersionPage> createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PackageProvider>(
      builder: (context, data, widget) {
        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            children: [
              ListTile(
                title: Text("当前版本"),
                trailing: Text("${data.currentVersion}(${data.buildNumber})"),
              ),
              ListTile(
                title: Text("最新版本"),
                trailing: Text(""),
              ),
            ],
          ),
        );
      },
    );
  }
}
