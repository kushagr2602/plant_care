# 🌿 PlantCare — AI-Powered Plant Maintenance App

A Flutter mobile app that uses AI to identify plants, create personalized care schedules, diagnose plant health issues, and gamify plant care with an RPG-style dashboard.

## Features

### 🤖 AI Plant Intelligence
- **Plant Identification**: Snap a photo → AI identifies plant type, species, and provides fun facts
- **Care Scheduling**: Auto-generates 4-week personalized maintenance plans (watering, fertilizing, pruning)
- **Plant Troubleshooting**: Photo a sick plant → AI diagnoses the issue and provides recovery steps

### 🎮 RPG Game Dashboard
- **Health System**: Plant HP (0-100) based on task completion and overdue tasks
- **XP & Leveling**: Earn XP for completing care tasks, level up your gardening skills
- **Streaks**: Track consecutive days of completed tasks with flame emojis
- **Achievements**: Unlock 8+ badges (Green Thumb, Master Gardener, Plant Doctor, etc.)

### 📅 Dietician-Style Schedule
- **Weekly View**: 7-column calendar showing tasks grouped by day and time
- **Smart Reminders**: Local notifications for upcoming tasks
- **Quick Actions**: Complete/skip tasks with instant XP feedback

## Tech Stack

- **Frontend**: Flutter (iOS + Android)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Firebase (optional)
- **AI**: Google Gemini 2.0 Flash

## Getting Started

### Prerequisites
- Flutter 3.22.0+
- Gemini API key (free at https://ai.google.dev/)

### Installation

```bash
git clone https://github.com/kushagrgupta/plant-care.git
cd plant_care
flutter pub get
flutter run -d chrome
```

### Setup Gemini API

1. Get free key: https://ai.google.dev/
2. Edit `lib/domain/providers/gemini_provider.dart`
3. Replace `YOUR_GEMINI_API_KEY_HERE` with your key
4. To enable real API calls, edit `lib/domain/providers/ai_provider.dart` and uncomment the real implementation

## Architecture

- **Clean Architecture**: Separated into core, data, domain, presentation layers
- **Riverpod State**: Providers for data, notifiers for mutations
- **Repository Pattern**: Abstract interfaces with mock implementations for testing
- **Mock-Ready**: Full UI testing without Firebase or APIs

## Game Mechanics

### XP Rewards
- Watering: 10 XP
- Sunlight: 5 XP
- Fertilizing: 25 XP
- Pruning: 30 XP
- All tasks done: +20 bonus
- 7-day streak: +100 bonus

### Badges (8 Total)
🌱 Green Thumb | 🪴 Collector | 🔥 Week Warrior | 💪 Iron Gardener | 💚 Plant Doctor | 🔬 Botanist | ⭐ Rising Gardener | 👑 Master Gardener

## Support

Open an issue on GitHub!

---

Made with 💚 by [Kushagr](https://github.com/kushagrgupta)
