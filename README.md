# Family Voice Client

*  Web
- from command line, execute `./setupChromeCorsOverride.sh`
   this allows the app to run w/o CORS - otherwise your images won't display
-  use flutter channel master
-  update lib/main_web.dart w/
   -  isSecured=true
   -  isWeb= true
   -  apiBaseUrl= 'https://myfamilyvoice.com'
-  flutter clean
-     
-  copy files from `build/web' to `voiceClientWeb` and commit
-  go to 192.168.1.44 and `pull` 
-  change `nginx/sites` change the `web_server` to port 3004
-  from `flutter/voiceUtils/nginx` run `restart.sh`

When testing locally web, be sure to source `setupChromeCorsOverride.sh` so that Chrome startups w/o supporting CORS

For testing locally (use target: Chrome SKIA)
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