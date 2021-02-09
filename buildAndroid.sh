source ./gradle.properties.sh
flutter build apk --split-per-abi -t lib/main_prod.dart
flutter install
