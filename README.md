# 🏡 RoommateSync

**RoommateSync** is a powerful and intuitive Flutter application designed to simplify shared living. Whether it’s tracking tasks, splitting expenses, planning group activities, or keeping memories with your roommates, RoommateSync keeps everything organized in one place.

---

## ✨ Features

### ✅ Implemented

- 🔐 **Authentication**
  - Sign in with Email/Password or Google
  - Secure login and logout

- 👥 **Room Management**
  - Join or create shared rooms using a unique room code

- ✅ **Task Management**
  - Add, assign, and complete tasks
  - Statistics for assigned vs. completed tasks
  - Automatic task deletion after completion or deadline

- 💸 **Expense Management**
  - Add and split expenses among selected roommates
  - Track balances for each member
  - Multi-select dropdown to assign expense shares

- 📲 **Push Notifications**
  - Task assignment, completion, and deadline reminders
  - Poll creation announcements

- 📷 **Camera & Album**
  - Take pictures, videos or select from the gallery
  - Upload and store them in Firestore
  - View shared photo memories within the app

- 📊 **Poll System**
  - Create polls to plan activities
  - "Plan Activity" button for scheduling without polls

- 📈 **Statistics Dashboard**
  - Overview of tasks in a clean, visual format

---

### 🚧 Planned

- 💰 **UPI Integration**
  - Add UPI ID for each roommate
  - Direct redirection to UPI apps with pre-filled data
  - Auto-update payment status and remove completed expenses

- 📅 **Planned Activity Notifications**
  - Integrate shared calendar reminders for scheduled events
  - Random fun prompts and activity suggestions
  - Notify roommates about upcoming shared plans
  - Announce the winning activity via notification

---

## 🛠️ Tech Stack

- **Flutter**
- **Firebase Auth & Firestore**
- **Firebase Cloud Messaging**
- **Cloudinary (for image and videos uploads)**
- **Push Notifications**
- **Provider (State Management)**

---

## 🚀 Getting Started

### 🔧 Prerequisites

- Flutter SDK (latest)
- Firebase Project (Firestore, Auth, Cloud Messaging)
- Cloudinary account (for image storage)
- Android Studio / VSCode
- Internet Connection

### 📦 Installation

```bash
git clone https://github.com/your-username/RoommateSync.git
cd RoommateSync
flutter pub get
