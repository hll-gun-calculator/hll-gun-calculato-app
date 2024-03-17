import 'data/Url.dart';
import 'main.dart';

import 'constants/api.dart';

void main() async {
  Config.prod(
    api: {
      "web_github": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "github.com"),
      "app_web_site": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "hll-gun-calc.app-document.cabbagelol.net"),
    },
  );

  runMain();
}
