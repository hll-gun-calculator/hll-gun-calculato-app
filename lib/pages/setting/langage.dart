/// 语言选择器
import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/provider/translation_provider.dart';
import '/utils/index.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  TranslationProvider? langProvider;

  List languages = [
    {
      "name": "zh_CN",
      "fileName": "zh",
      "label": "中文",
    },
    // {
    //   "name": "en_US",
    //   "fileName": "en",
    //   "label": "English",
    // }
  ];

  String currentPageSelectLang = "";

  @override
  void initState() {
    super.initState();

    langProvider = ProviderUtil().ofLang(context);

    if (langProvider!.currentLang.isEmpty) {
      Future.delayed(Duration.zero, () async {
        setState(() {
          langProvider!.currentLang = FlutterI18n.currentLocale(context)!.languageCode;
        });
      });
    }

    setState(() {
      // 初始页面语言值
      currentPageSelectLang = langProvider!.currentLang;
    });
  }

  /// [Event]
  /// 改变当前页面选择的语言
  /// 未保存
  void setCurrentPageSelectLang(String value) {
    if (value.isEmpty) return;
    setState(() {
      currentPageSelectLang = value;
    });
  }

  /// [Event]
  /// 变动语言
  void saveLocalLanguage(BuildContext context) async {
    if (currentPageSelectLang == langProvider!.currentLang) return;

    await FlutterI18n.refresh(context, Locale(currentPageSelectLang));

    setState(() {
      langProvider!.currentLang = currentPageSelectLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "setting.language.title")),
        actions: [
          if (currentPageSelectLang != langProvider!.currentLang)
            IconButton(
              onPressed: () => saveLocalLanguage(context),
              icon: const Icon(Icons.done),
            )
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return BackButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      body: Consumer<TranslationProvider>(
        builder: (BuildContext context, data, Widget? child) {
          return ListView(
            children: languages.map((lang) {
              return RadioListTile<String>(
                value: lang["fileName"].toString(),
                onChanged: (value) => setCurrentPageSelectLang(value as String),
                groupValue: currentPageSelectLang,
                title: Text(
                  lang["label"].toString(),
                  style: Theme.of(context).listTileTheme.titleTextStyle,
                ),
                secondary: Wrap(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: Text(lang["name"]),
                      ),
                    ),
                  ],
                ),
                selected: true,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
