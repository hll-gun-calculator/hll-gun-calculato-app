import 'dart:io';

import 'constants/api.dart';
import 'data/Url.dart';
import 'main.dart';

void main() async {
  Config.dev(
    api: {
      "web_github": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "github.com"),
      "app_web_site": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban-app.cabbagelol.net"),
      "web_site": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban.com"),
    },
  );

  runMain();
}
