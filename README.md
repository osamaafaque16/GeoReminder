# 📍 GeoReminder

GeoReminder is an iOS application that helps users create **geofence-based reminders** and receive notifications when they **enter or exit a specific location**.  
The app also provides insights into **daily step count** and **current activity state** using HealthKit and Core Motion.

---

## 🚀 Key Features

- 📍 Location-based (Geofence) reminders
- 🔔 Entry & exit notifications with snooze support
- 🗺 Interactive map with saved reminder locations
- 🚶‍♂️ Live activity detection (Walking, Cycling, Driving, etc.)
- 👣 Fetch today’s step count
- 🗂 Persistent local storage using Core Data
- ⚡ Live search with debounce using Combine

---

## 📱 Screens Overview

![image alt](https://github.com/osamaafaque16/GeoReminder/blob/12d34a365667d4d1b6858c3e956ce53ca44a51fa/IMG_1.PNG)
![image alt](https://github.com/osamaafaque16/GeoReminder/blob/1146c2569231dee6d1685a9a11cba4a6925819ca/IMG_2.PNG)

### 1️⃣ Dashboard View

The **Dashboard View** acts as the central hub of the app.

**Features:**
- **Fetch Today Step Count**
  - Displays today’s step count using **HealthKit**
  - Shows a loading indicator while fetching data
- **User Activity State Widget**
  - Displays current activity such as:
    - Walking
    - Cycling
    - Driving
    - Stationary
  - Powered by **Core Motion**
- **Reminder Listing**
  - Displays all saved reminders
  - User can:
    - View reminder details
    - Delete reminders
- **Completed Reminder Behavior**
  - If a reminder is marked as completed:
    - It no longer appears as a geofence on the map
    - It remains visible only in the dashboard reminder list
- **Delete Reminder**
  - Deleting a reminder removes it permanently from **Core Data**
- **Show Map Button**
  - Displays all saved geofence reminders on the map

---

### 2️⃣ Reminder Detail View

The **Reminder Detail View** allows users to manage a specific reminder.

**Features:**
- View full reminder details
- Mark a reminder as completed
- **View on Map**
  - Shows only the selected reminder’s location on the map

---

### 3️⃣ Map Search View

The **Map Search View** allows users to search and manage geofence locations.

**Features:**
- Search for specific locations using a search bar
- Live search with **debounce (Combine)**
- Add reminders by tapping:
  **“Add Reminder to this Location”**
- Displays:
  - All active reminders as map markers
  - All saved geofence regions
- **Geofence Overlay Colors**
  - 🔵 Blue → User is outside the region
  - 🟢 Green → User is inside the region
- Shows only **active reminders** on the map

---

## 🔔 Notifications

- Location notifications are triggered when:
  - User **enters** a geofence
  - User **exits** a geofence
- Users can **snooze notifications for 5 minutes**

---

## 🧠 Architecture

The app follows **MVVM (Model–View–ViewModel)** architecture:

- **View**: SwiftUI views
- **ViewModel**: Business logic, state handling, Core Data & location logic
- **Model**: Core Data entities and domain models

This ensures:
- Clean separation of concerns
- Better maintainability
- Scalable architecture

---

## 🛠 Tech Stack

- **Swift**
- **SwiftUI**
- **UIKit**
- **HealthKit** (Step Count)
- **Core Motion** (Activity Detection)
- **Core Location** (Geofencing)
- **MapKit** (Maps & Annotations)
- **Combine** (Debounce & reactive updates)
- **Core Data** (Local Storage)
- **MVVM Architecture**

---

## 🔐 Permissions

GeoReminder requires the following permissions:

- 📍 Location (When In Use)
- 📍 Location (Always) – required for geofencing
- 👣 HealthKit – for step count data
- 🚶‍♂️ Motion & Fitness – for activity detection
- 🔔 Notifications – for reminder alerts

---



