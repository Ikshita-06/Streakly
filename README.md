# Streakly

Streakly is a habit-tracking mobile application built with **Flutter** and **Supabase**, designed to help users build consistent daily routines. It combines secure authentication, automated streak tracking, and a responsive interface to make habit tracking simple and engaging.

## Features

### Habit Management
- Create, view, and delete daily habits.
- Log habit completions and track daily progress.
- Prevent duplicate completion logs for the same habit on a given day using database constraints.

### Streak Tracking
- Automatically calculates current and longest streaks.
- Updates streaks when a habit is completed.
- Detects missed days and resets broken streaks.
- Uses date-based checks to maintain streak consistency.

### User Interface
- Light and dark theme with persistent preferences.
- Interactive streak indicators with dynamic fire icons.
- Responsive layouts with text-overflow handling.
- Snackbars for feedback and confirmation dialogs for important actions.

### Authentication & Security
- Email/password authentication using Supabase.
- PostgreSQL database for storing user and habit data.
- Row Level Security (RLS) policies to restrict users to their own data.

## Tech Stack

| Category | Technologies |
|---|---|
| Frontend | Flutter, Dart |
| Backend | Supabase |
| Database | PostgreSQL |
| Authentication | Supabase Auth |
| State Management | Provider |
| Database Security | Row Level Security (RLS) |

## How Streak Tracking Works

Streakly uses date-based checks to maintain accurate habit streaks:

1. **Daily validation:** On app launch, the app checks the latest completion date for each habit. A streak is reset if the user has missed the previous day.
2. **Habit completion:** When a habit is completed, the app checks whether it was also completed yesterday.
   - If yes, the current streak increases by one.
   - If not, a new streak starts at one.
3. **Longest streak:** The longest streak is maintained separately to preserve the user's best progress.

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK
- A Supabase project

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Ikshita-06/streakly.git
   cd streakly
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Supabase:

   Add your Supabase project URL and anon key in `lib/main.dart`.

4. Run the application:

   ```bash
   flutter run
   ```

## Screenshots

![Streakly Screenshot 1](https://github.com/user-attachments/assets/5f0c9f7d-87d5-4c4d-a082-db603746d742)

![Streakly Screenshot 2](https://github.com/user-attachments/assets/d4d21ffb-21bd-40ec-aaf9-383aa6fdb973)

![Streakly Screenshot 3](https://github.com/user-attachments/assets/dc9edc2f-b713-4391-8e03-d4cfa534d617)

---

**Built by Ikshita Sharma**

---
