# PomoFocus Pro 🍅⚡

> A modern, sleek, and high-performance **Pomodoro & Focus Productivity Timer** built with Flutter for Web, Windows Desktop, macOS, Linux, iOS, and Android.

---

## ✨ Features

- **🎯 Precision Pomodoro Timer Flow**:
  - Focus session (default 25 min, customizable 10–60 min)
  - Short Break (default 5 min, customizable 1–15 min)
  - Long Break (default 15 min, customizable 5–45 min)
  - Customizable Long Break Interval (default 4 sessions)
  - Round & cycle tracking with visual tomato progress dots (`Round X of Y`)

- **🎨 5 Curated Designer Themes**:
  - **Midnight Cyan**: Deep obsidian with electric cyan and purple neon accents.
  - **Tomato Crimson**: Classic Pomodoro dark aesthetic with coral red and mint teal.
  - **Nordic Zen**: Forest green ambiance with sage and sky blue highlights.
  - **Cyber Sunset**: Twilight violet with radiant coral and warm amber.
  - **Ivory Minimal**: Clean porcelain aesthetic with modern indigo and crisp styling.

- **📋 Integrated Task & Sprint Management**:
  - Create, edit, and categorize focus tasks (`Work`, `Study`, `Coding`, `Design`, `Personal`).
  - Set estimated Pomodoro target counts (e.g. 🍅 4).
  - Set active objective with 1 tap: automatically increments completed pomodoro count as you finish focus sessions!
  - Filter tasks by status (`All`, `Active`, `Completed`) and categories.

- **📊 Productivity Analytics & Streaks**:
  - 4 Key performance indicators: Today's Focus Time, Sessions Completed Today, Active Streak (days 🔥), and Total Focus Hours.
  - **7-Day Interactive Focus Bar Chart** with daily totals and today highlight.
  - Recent session history timeline with duration badges and linked task titles.

- **🔊 Audio & Soundscapes**:
  - Gentle Tibetan bell / chord chime on session completion.
  - Tactile audio feedback on interactions.
  - Procedural focus ambient soundscapes: **Rain**, **Brown / White Noise**, **Clock Tick**, or **Off** with volume slider.

- **📱 Fully Responsive Design**:
  - **Desktop / Web Layout**: Split-screen view with hero timer on the left and tabbed tasks/analytics on the right.
  - **Mobile / Narrow Layout**: Fluid bottom navigation with dedicated Timer, Tasks, and Analytics views.

- **💾 Local Persistence**:
  - Instant offline storage using `shared_preferences`. Your settings, tasks, history, and streak are automatically saved across sessions.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.7.0+)
- Google Chrome or Edge (for Web)
- Visual Studio / C++ Build Tools (for Windows desktop)

### Running Locally

To run in your browser (Chrome):
```bash
flutter run -d chrome
```

To run on Windows Desktop:
```bash
flutter run -d windows
```

### Running Tests

```bash
flutter test
```

### Building for Web Production

```bash
flutter build web
```

---

## 📁 Project Architecture

```
lib/
├── main.dart                      # App entry point & initialization
├── models/
│   ├── pomodoro_settings.dart     # Timer settings & theme configuration
│   ├── session_record.dart        # Session history entity
│   └── task_item.dart             # Task & sprint entity
├── screens/
│   └── home_screen.dart           # Responsive home layout & timer orchestrator
├── services/
│   ├── sound_service.dart         # Multiplatform audio service
│   ├── sound_service_stub.dart    # Native audio fallback
│   ├── sound_service_web.dart     # Web Audio API procedural audio
│   └── storage_service.dart       # SharedPreferences persistence & analytics
├── theme/
│   └── app_theme.dart             # 5 Curated theme palettes & typography
└── widgets/
    ├── analytics_widget.dart      # KPI cards, 7-day bar chart, history
    ├── mode_selector.dart         # Animated pill mode tabs
    ├── settings_dialog.dart       # Settings modal with sliders & switches
    ├── task_list_widget.dart      # Task management with add/edit modal
    ├── timer_circle.dart          # Gradient ring painter & pulse animation
    └── timer_controls.dart        # Glowing Play/Pause, Skip, Reset, +5m
```
