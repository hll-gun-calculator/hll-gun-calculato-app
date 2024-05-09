import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'constants/config.dart';
import 'router/router.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart' show FlutterNativeSplash;
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_web_plugins/url_strategy.dart' show usePathUrlStrategy;

import 'constants/api.dart';
import 'provider/calc_provider.dart';
import 'provider/theme_provider.dart';
import 'provider/collect_provider.dart';
import 'provider/history_provider.dart';
import 'provider/package_provider.dart';
import 'provider/translation_provider.dart';
import 'provider/gun_timer_provider.dart';
import 'provider/map_provider.dart';
import 'provider/home_app_provider.dart';

void runMain() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 初始持久-前缀名称
  SharedPreferences.setPrefix("Hll.");

  // 路由初始
  Routes.configureRoutes(FluroRouter());
  usePathUrlStrategy();

  // 设置系统状态栏
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const App());

  FlutterNativeSplash.remove();
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TranslationProvider()),
        ChangeNotifierProvider(create: (context) => HistoryProvider()),
        ChangeNotifierProvider(create: (context) => CollectProvider()),
        ChangeNotifierProvider(create: (context) => CalcProvider()),
        ChangeNotifierProvider(create: (context) => MapProvider()),
        ChangeNotifierProvider(create: (context) => PackageProvider()),
        ChangeNotifierProvider(create: (context) => GunTimerProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => HomeAppProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (BuildContext context, ThemeProvider themeData, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: Config.env == Env.DEV,
            theme: themeData.currentThemeData,
            themeAnimationDuration: Duration.zero,
            initialRoute: '/splash',
            supportedLocales: const [
              Locale('zh', 'CH'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: [
              FlutterI18nDelegate(
                translationLoader: FileTranslationLoader(
                  useCountryCode: true,
                  useScriptCode: true,
                  basePath: "assets/lang",
                  fallbackFile: "zh_CH",
                  decodeStrategies: [JsonDecodeStrategy()],
                ),
              ),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            builder: (BuildContext context, Widget? widget) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return WidgetError(errorDetails: errorDetails);
              };

              return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(themeData.theme.textScaleFactor!),
                  ),
                  child: OverflowBox(
                    maxWidth: constraints.maxWidth > AppSize.kRang ? double.parse(AppSize.kRang.toString()) : MediaQuery.of(context).size.width,
                    minWidth: AppSize.kMinRang,
                    fit: OverflowBoxFit.deferToChild,
                    alignment: Alignment.center,
                    child: ClipRRect(
                      clipBehavior: kIsWeb ? Clip.hardEdge : Clip.none,
                      child: widget!,
                    ),
                  ),
                );
              });
            },
            onGenerateRoute: Routes.router.generator,
          );
        },
      ),
    );
  }
}

class WidgetError extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;

  const WidgetError({
    Key? key,
    required this.errorDetails,
  })  : assert(errorDetails != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.error,
      margin: EdgeInsets.zero,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.error),
      ),
    );
  }
}
