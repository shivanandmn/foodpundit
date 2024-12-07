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
