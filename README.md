# Kinetic

Kinetic (formerly SteadyTrend) is a Flutter-based mobile application designed for tracking weight over time. The app focuses on displaying long-term trends rather than daily fluctuations, helping users stay motivated by looking at the bigger picture.

## Features

- **Trend-based Weight Tracking**: Visualize your weight journey focusing on a moving trend line.
- **Goal Setting**: Set and monitor your target weight goal.
- **Unit Preferences**: Seamlessly toggle between Pounds (LBS) and Kilograms (KG).
- **Daily Reminders**: Optional local notifications to remind you to log your weight.
- **Privacy First**: All weight data is securely stored locally on your device using SharedPreferences.

## Built With

- **Flutter**: The cross-platform framework used for development.
- **Provider**: For state management across the application.
- **fl_chart**: For rendering clean, interactive trend line charts.
- **shared_preferences**: For persistent, local device storage.
- **flutter_local_notifications**: For scheduling and managing daily reminder alerts.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version ^3.11.0 or newer)
- Android Studio / Xcode for device emulation and platform compilation.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/kinetic.git
   cd kinetic
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Development and Deployment

For specific instructions regarding generating app icons, building release APKs, and managing standard deployment procedures, please see our [DEPLOYMENT.md](DEPLOYMENT.md).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Open Source Acknowledgments

This app is built using several incredible open-source packages:

- `flutter`: BSD 3-Clause License
- `provider`: MIT License
- `fl_chart`: MIT License
- `shared_preferences`: BSD 3-Clause License
- `flutter_local_notifications`: BSD 3-Clause License
- `timezone`: MIT License
- `flutter_timezone`: MIT License
- `intl`: BSD 3-Clause License

Special thanks to the open-source community for making these tools freely available.
