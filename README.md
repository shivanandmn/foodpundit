# foodpundit

A new Flutter project.

## clean build

```[Lab:
flutter clean


cd android
./gradlew clean

# Go back to project root
cd ..
# Get Flutter dependencies again
flutter pub get
# Rebuild the project
flutter build apk

```

- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

```
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```



```

flutter build apk --release


firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app 1:1059157977403:android:d3a3f8f3a8d0f3b7e8a8b8 --groups testers --release-notes Initial test release


```
