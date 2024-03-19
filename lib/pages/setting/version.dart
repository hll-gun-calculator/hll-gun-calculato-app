
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/component/_empty/index.dart';
import '/constants/api.dart';
import '/constants/app.dart';
import '/data/index.dart';
import '/provider/package_provider.dart';
import '/utils/index.dart';

class VersionPage extends StatefulWidget {
  const VersionPage({super.key});

  @override
  State<VersionPage> createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  NewVersion? newVersion = NewVersion();

  Versions? versions = Versions(
    list: [],
  );

  @override
  void initState() {
    _getNewVersion();
    _getHistoryVersion();
    super.initState();
  }

  /// 获取最新版本
  void _getNewVersion() async {
    setState(() {
      newVersion!.load = true;
    });

    Response result = await Http.request(
      "config/newVersion.json",
      method: Http.GET,
      httpDioValue: "app_web_site",
    );

    if (result.data != null) {
      setState(() {
        newVersion = NewVersion.fromJson(result.data);
      });
    }

    setState(() {
      newVersion!.load = false;
    });
  }

  /// 获取历史版本列表
  void _getHistoryVersion() async {
    setState(() {
      versions!.load = true;
    });

    Response result = await Http.request(
      "config/versions.json",
      method: Http.GET,
      httpDioValue: "app_web_site",
    );

    if (result.data != null) {
      versions = Versions.fromJson(result.data);
    }

    setState(() {
      versions!.load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PackageProvider>(
      builder: (context, data, widget) {
        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            children: [
              ListTile(
                title: const Text("当前版本"),
                trailing: Text("${data.currentVersion}(${data.buildNumber})"),
              ),
              if (newVersion!.load)
                ListTile(
                  leading: newVersion!.load
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                  title: const Text("最新版本"),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    App.url.onPeUrl("${Config.apis["app_web_site"]!.url}/page/version.html");
                  },
                )
              else
                Column(
                  children: [
                    ListTile(
                      title: const Text("web"),
                      subtitle: Text(newVersion!.web.version),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        App.url.onPeUrl("${Config.apis["app_web_site"]!.url}/page/version.html");
                      },
                    ),
                    ListTile(
                      title: const Text("android"),
                      subtitle: Text(newVersion!.android.version),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        App.url.onPeUrl("${Config.apis["app_web_site"]!.url}/page/version.html");
                      },
                    ),
                    ListTile(
                      title: const Text("ios"),
                      subtitle: Text(newVersion!.ios.version),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        App.url.onPeUrl("${Config.apis["app_web_site"]!.url}/page/version.html");
                      },
                    )
                  ],
                ),
              const Divider(),
              if (versions!.load && versions!.list.isNotEmpty)
                Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 50),
                    child: const CircularProgressIndicator(),
                  ),
                )
              else if (!versions!.load && versions!.list.isEmpty)
                const EmptyWidget(),
              ...versions!.list
                  .map((e) => ListTile(
                        title: Text(e.version),
                        subtitle: Text(e.platform.keys.toList().join("\t").toString()),
                      ))
                  .toList(),
            ],
          ),
        );
      },
    );
  }
}
