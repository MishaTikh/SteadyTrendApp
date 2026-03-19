# Deployment Instructions

## Building an APK for Android

1. **Verify Setup**
   Ensure you have Flutter installed and configured correctly by running:
   ```bash
   flutter doctor
   ```

2. **Build the APK**
   Run the following command to build a release APK:
   ```bash
   flutter build apk --release
   ```
   *Note: This creates a "fat" APK that contains binaries for all architectures (arm, arm64, x64).*

3. **Locate the APK**
   Once the build completes successfully, you can find the generated APK file at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

4. **Share and Install**
   You can share this `.apk` file directly. To install it on an Android device, simply send the file to the device and open it. Ensure "Install from unknown sources" is enabled in the device's settings.

## Preparing for the Google Play Store

The Google Play Store requires an **App Bundle (.aab)** rather than an APK.

1. **Sign the App**
   Before you can upload to the Play Store, you must sign your app.
   - Follow the official Flutter documentation to create a keystore and configure signing in `android/app/build.gradle`:
     [https://docs.flutter.dev/deployment/android#signing-the-app](https://docs.flutter.dev/deployment/android#signing-the-app)

2. **Build the App Bundle**
   Run the following command to build a release app bundle:
   ```bash
   flutter build appbundle
   ```

3. **Locate the App Bundle**
   The generated `.aab` file will be located at:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```

4. **Upload to Google Play Console**
   - Go to the [Google Play Console](https://play.google.com/console).
   - Create a new app or select an existing one.
   - Navigate to **Production** (or Testing > Internal testing) from the left menu.
   - Click **Create new release**.
   - Upload the `.aab` file generated in step 3.
   - Fill out the release details and roll it out to users or testers!
