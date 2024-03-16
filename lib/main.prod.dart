import 'constants/api.dart';
import 'data/Url.dart';
import 'main.dart';

void main() async {
  Config.prod(
    api: {
      "web_github": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "github.com"),
      "app_web_site": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "document-amber-gamma.vercel.app"),
    },
  );

  runMain();
}
