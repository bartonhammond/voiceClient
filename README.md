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
-  flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=true -t lib/main_web_prod.dart     
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

*  Testing w/ Gherkin
   *  Note: the `voiceFileServer` and the `voiceServerBarton` have to be started with `export foo=barton`
   *  `flutter run -d CA0BCD8D-1EB0-4DFD-B452-BDA42C313C9A -t lib/main_integration_test.dart --verbose`
   *  take uri and update app_test
   *  If wanting to breakdown to steps and/or specific scenarios, use this
   *  `dart app_test_steps.dart --deleteTestUser=yes --deleteBook=yes --deleteBooksMessages=yes  --deleteFamilyTestUsers=yes --deleteStoryReactions=yes --deleteNineth=yes --runTag=all --uri=`
   * OR
   *   `dart app_test_steps.dart --deleteTestUser=no --deleteBook=no --deleteBooksMessages=no  --deleteFamilyTestUsers=no --deleteStoryReactions=no --deleteNineth=yes --runTag=nineth --uri=`
   * To run all the tests w/ deletion of data between scenarios, use this:
   * `dart app_test_main.dart --uri=`
   * Build report by running this
   *  `cp report.json ~/flutter/cucumber` and run `node index.js`
   * Then in `~/flutter/cucumber`, commit the changes and push
   * View the report: `https://bartonhammond.github.io/mfv-gherkin/`
