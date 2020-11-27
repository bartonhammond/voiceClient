# Family Voice Client

*  Web
-  use flutter channel master
-  update lib/main.dart w/
   -  isSecured=true
   -  isWeb= true
   -  apiBaseUrl= 'https://myfamilyvoice.com'
-  flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=true
