ales Bets
Sales Bets is a fun and engaging mobile application designed to gamify sales challenges within a company. It allows users to place "bets" using virtual credits on the outcome of sales events and teams, fostering a competitive and exciting work environment.

Features
Gamified Betting: Users can place virtual bets on sales teams and events.

Team & Event Pages: Detailed views for each team and sales event, including stats, members, and a betting interface.

Leaderboards: A dynamic leaderboard to track top performers and teams.

User Profiles: Users can follow their favorite teams and view their betting history.

Firebase Integration: Utilizes Firestore for a real-time, scalable backend.

Tech Stack
Flutter: Cross-platform framework for building the mobile application.

Dart: The programming language used by Flutter.

Firebase:

Firestore: NoSQL cloud database for storing application data (events, teams, users, bets).

Authentication: (Partially implemented) for user login and signup.

Provider: A powerful state management solution for a clean and scalable architecture.

shared_preferences: Used for local storage, specifically for the data seeding process.

Getting Started
Prerequisites
Flutter SDK: Install Flutter

Firebase Account: A free Firebase account is required.

Node.js: Needed for the Firebase CLI.

Installation
Clone the repository:

Bash

git clone https://github.com/your-username/sales_bets.git
cd sales_bets
Configure Firebase:

Create a new Firebase project in the Firebase Console.

Register your Android and iOS apps.

Follow the instructions to download the google-services.json (for Android) and GoogleService-Info.plist (for iOS) and place them in the correct directories (android/app/ and ios/Runner/ respectively).

Install the Firebase CLI and login:

Bash

npm install -g firebase-tools
firebase login
Configure your Flutter project to use Firebase:

Bash

flutter pub add firebase_core
flutterfire configure
Install dependencies:

Bash

flutter pub get
Run the app:
The app includes a data seeder that automatically populates your Firebase database with sample data the first time you run it.

Bash

flutter run
Project Structure
The project follows a modular and provider-based architecture for better organization and scalability.

/sales_bets
├── lib/
│   ├── core/               # Core services (Auth, Firestore, etc.)
│   ├── models/             # Data models
│   ├── providers/          # State management logic
│   ├── views/              # UI screens
│   ├── widgets/            # Reusable UI components
│   └── main.dart           # App entry point
├── pubspec.yaml            # Project dependencies
└── README.md
