# 🔥 Streakly

**Streakly** is a full-stack mobile application designed to help users build and maintain consistent daily habits. Built with **Flutter** for the frontend and **Supabase** for the backend, it features a robust streak calculation algorithm, secure authentication, and a modern, responsive UI.

---
## Features

### Core Functionality
* **Habit Management:** Users can create, view, and delete habits effortlessly.
* **Smart Streak Tracking:**
    * **Real-time Updates:** Instantly updates "Current Streak" and "Longest Streak" upon completion.
    * **Auto-Reset Logic:** A dedicated algorithm runs on app launch to detect missed days. If a user fails to log a habit yesterday, their streak automatically resets to 0.
* **Daily Logging:** Prevents multiple logs for the same habit on the same day using unique database constraints.

### UI/UX
* **Dynamic Theme Switching:** Toggle between Dark Mode and Light Mode with state persistence.
* **Interactive Feedback:** Fire icons change color to represent intensity (Orange for short streaks, Deep Orange for streaks over 5 days).
* **Responsive Layouts:** Handles text wrapping and screen overflow gracefully.
* **User Feedback:** Snackbars for errors and confirmation dialogs for critical actions like deletion.

### Backend & Security
* **Supabase Authentication:** Secure Email/Password signup and login.
* **Row Level Security (RLS):** Database policies ensure users can *only* access and modify their own data.

---

## Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Supabase (PostgreSQL, Auth)
* **State Management:** Provider
* **Database Security:** Row Level Security (RLS)

---

## The "Streak" Algorithm

The app ensures streak integrity through a two-step verification process:

1.  **On App Load (The Daily Check):**
    The app queries the database for the last completed date of every habit. If the last log was not **today** or **yesterday**, the streak is considered broken and automatically resets to 0.

2.  **On Completion:**
    When a habit is marked as done, the system checks if a log exists for **yesterday**.
    * **If Yes:** The streak increments (+1).
    * **If No:** The streak starts fresh at 1.

---

## Getting Started

1.  **Clone the repo:**
    ```bash
    git clone https://github.com/Ikshita-06/streakly.git
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Setup Supabase:**
    Add your `url` and `anonKey` in `lib/main.dart`.
4.  **Run the app:**
    ```bash
    flutter run
    ```

---

**Built by Ikshita Sharma**
