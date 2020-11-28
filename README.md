# Family Voice Client

*  Web
-  use flutter channel master
-  update lib/main.dart w/
   -  isSecured=true
   -  isWeb= true
   -  withCors = true //at least until the USE_SKIA is used
   -  apiBaseUrl= 'https://myfamilyvoice.com'
-  flutter clean
-  flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=true
-  copy files from `build/web' to `voiceClientWeb` and commit
-  go to 192.168.1.44 and `pull` 
-  change `nginx/sites` change the `web_server` to port 3004
-  from `flutter/voiceUtils/nginx` run `restart.sh`

When testing locally web, be sure to source `setupChromeCorsOverride.sh` so that Chrome startups w/o supporting CORS

For testing locally: 
```
final configuredApp = AppConfig(
    flavorName: 'Dev',
    apiBaseUrl:
        'http://192.168.1.13', //https://myfamilyvoice.com', //http://192.168.1.13', //'http://dev-myfamilyvoice.com',
    getHttpLink: getHttpLink,
    isSecured: true,
    isWeb: true,
    withCors: false,
    child: MyApp(),
  );
```