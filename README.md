# 🌱 Plant Care

A Flutter mobile app that helps you manage and care for your plants. Track your plant collection, get smart watering reminders, identify plants with AI, and access expert care tips — all in one place.

## Features

- **Smart Watering Reminders** — Set custom watering schedules (1x, 2x, 3x daily, or fully custom times) and receive daily local notifications so you never forget to water.
- **AI Plant Identification** — Take a photo or pick one from your gallery and the app identifies the plant using the [Plant.id API](https://plant.id), returning the name, confidence score, and similar images.
- **Plant Collection** — Add plants with a photo and watering schedule. View, manage, and delete your plants from the home screen.
- **Plant Care Tips** — Browse expert guidance on watering, light, soil, common problems, seasonal care, and pro tips.
- **Authentication** — Sign in with email/password or Google. Plant identification requires an account.

## Screenshots

> Add screenshots here.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart SDK ^3.10.4) |
| Auth | Firebase Authentication + Google Sign-In |
| Backend | Firebase Cloud Functions |
| Local Storage | JSON file via `path_provider` |
| Notifications | `flutter_local_notifications` + `timezone` |
| Plant ID API | [Plant.id v2](https://plant.id) |
| Animations | Lottie |
| State | `ValueNotifier` |

## Project Structure

```
lib/
├── main.dart                      # Entry point, theme, Firebase init
├── firebase_options.dart          # Auto-generated Firebase config
├── auth/
│   └── auth.dart                  # AuthService (email + Google)
├── content/
│   ├── widgetree.dart             # Main scaffold with bottom nav
│   ├── page/
│   │   ├── onboarding_screen.dart # Animated intro (Lottie)
│   │   ├── login.dart             # Sign in page
│   │   ├── signup.dart            # Create account page
│   │   ├── home.dart              # Plant collection
│   │   ├── picture.dart           # Plant identification
│   │   └── tips.dart              # Care tips guide
│   └── common/
│       ├── build_form.dart        # Add plant form
│       ├── navbar.dart            # Bottom navigation bar
│       ├── personal_plant_card.dart
│       └── plant_card.dart        # Identification result card
├── notifications/
│   └── notification_service.dart  # Schedule/cancel local notifications
├── store/
│   ├── tojson.dart                # PlantEntry model + JSON persistence
│   └── migration.dart             # Data schema migration
└── notifier/
    └── value.dart                 # Tab index notifier
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.10.4 or later
- A Firebase project with Authentication enabled (Email/Password and Google)
- A [Plant.id API key](https://plant.id)

### Setup

1. **Clone the repo**

   ```bash
   git clone <repo-url>
   cd plant_care
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure environment variables**

   Create a `.env` file in the project root:

   ```env
   PLANT_ID_KEY=your_plant_id_api_key_here
   ```

4. **Configure Firebase**

   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Email/Password** and **Google** sign-in methods
   - Run the FlutterFire CLI to generate `lib/firebase_options.dart`:

     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```

   - Add `google-services.json` to `android/app/` and `GoogleService-Info.plist` to `ios/Runner/`

5. **Run the app**

   ```bash
   flutter run
   ```

## Notifications

Watering reminders are scheduled as daily local notifications using `flutter_local_notifications`. The app requests notification permissions on first launch. When a plant is deleted, its scheduled notifications are automatically cancelled.

Supported schedules:
- Once a day — 12:00 PM
- Twice a day — 8:00 AM, 8:00 PM
- Three times a day — 7:00 AM, 1:00 PM, 7:00 PM
- Custom — pick your own times

## Data Storage

Plant data is stored locally as a JSON file (`plants.json`) in the app's documents directory. A migration utility handles schema updates between app versions.

## Dependencies

Key packages used:

```yaml
firebase_auth: ^6.1.3
firebase_core: ^4.3.0
cloud_functions: ^6.0.5
google_sign_in: ^6.2.0
flutter_local_notifications: ^18.0.1
timezone: ^0.9.4
image_picker: ^1.1.2
http: ^1.6.0
connectivity_plus: ^6.0.5
flutter_dotenv: ^6.0.0
path_provider: ^2.1.5
lottie: ^3.1.2
font_awesome_flutter: ^10.7.0
```

## License

This project is private and not published to pub.dev.
