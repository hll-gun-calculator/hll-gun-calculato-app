import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '/utils/index.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  UrlUtil urlUtil = UrlUtil();

  /// 打开计算配置
  void _openCalculatingFunctionConfig() {
    urlUtil.opEnPage(context, "/calculatingFunctionConfig");
  }

  /// 包管理
  void _openMapPackage() {
    urlUtil.opEnPage(context, "/setting/mapPackage");
  }

  /// 首页面板配置
  void _openHomeAppConfig () {
    urlUtil.opEnPage(context, "/setting/homeAppConfig");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ListTile(
            title: Text(FlutterI18n.translate(context, "calculatingFunctionConfig.title")),
            onTap: () => _openCalculatingFunctionConfig(),
          ),
          ListTile(
            title: Text(FlutterI18n.translate(context, "setting.cell.mapConfig.title")),
            onTap: () => _openMapPackage(),
          ),
          ListTile(
            title: Text(FlutterI18n.translate(context, "setting.cell.homeAppConfig.title")),
            onTap: () => _openHomeAppConfig(),
          ),
          const Divider(),
          ListTile(
            title: const Text("语言"),
            onTap: () => urlUtil.opEnPage(context, "/language"),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            title: const Text("主题"),
            onTap: () => urlUtil.opEnPage(context, "/theme"),
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(),
          ListTile(
            title: Text(FlutterI18n.translate(context, "license.title")),
            onTap: () => urlUtil.opEnPage(context, "/license"),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            title: const Text("网站"),
            onTap: () => urlUtil.onPeUrl("https://hll-app.cabbagelol.net"),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
