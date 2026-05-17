# ServiceSathi AI 🤖

**Agentic AI Service Orchestrator for the Informal Economy**

A premium Flutter mobile application that uses multi-agent AI workflows to intelligently book local services (AC repair, plumbing, electrical, beauty, tutoring, mechanics) through natural language interaction in **English, Urdu, and Roman Urdu**.

---

## ✨ Features

- 🧠 **AI-Powered Intent Understanding** — Describe your need in any language
- 🔍 **Smart Provider Discovery** — Find nearby, verified service providers
- 📊 **Intelligent Ranking** — AI scores and ranks providers with transparent reasoning
- 📋 **Booking Simulation** — End-to-end booking flow with confirmation
- 🔔 **Automated Follow-Ups** — AI-scheduled reminders and feedback
- 🔗 **Agent Workflow Visualization** — See every AI agent step with confidence scores

## 🏗️ Architecture

### Multi-Agent Pipeline
```
User Input → Intent Agent → Discovery Agent → Ranking Agent → Booking Agent → Follow-Up Agent
```

### 6 Specialized AI Agents
| Agent | Role |
|-------|------|
| Intent Agent | Natural language understanding (multilingual) |
| Discovery Agent | Provider search & filtering |
| Ranking Agent | Multi-criteria scoring & reasoning |
| Booking Agent | Booking simulation & confirmation |
| Follow-Up Agent | Reminder scheduling & automation |
| Logger Agent | Workflow audit trail & monitoring |

## 📱 Screens

1. **Splash Screen** — Animated gradient with orbiting particles
2. **Onboarding** — 3-page AI feature introduction
3. **Home** — Search, categories, AI suggestions, recent bookings
4. **AI Processing** — Live extraction animation with intent reveal
5. **Recommendations** — Ranked providers with AI scores & reasoning
6. **Agent Workflow** — Futuristic pipeline visualization
7. **Booking Simulation** — Animated confirmation with details
8. **Follow-Up** — Automated timeline with status tracking
9. **Notifications** — Color-coded AI notification center
10. **Profile** — Stats, AI personalization, settings

## 🎨 Design System

- **Style**: Glassmorphism + Minimalism
- **Colors**: Deep blue, purple gradient, cyan highlights
- **Typography**: Google Fonts (Outfit)
- **Dark Mode**: Full support
- **Animations**: Pulsing orbs, elastic transitions, gradient effects

## 🛠️ Tech Stack

- **Flutter** (Dart)
- **Riverpod** (State Management)
- **Google Fonts** (Typography)
- **Material 3** (Design System)

## 🚀 Getting Started

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/servicesathi-ai.git
cd servicesathi-ai

# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run
```

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry + navigation
├── config/
│   ├── colors.dart              # Color system
│   └── theme.dart               # Light/dark themes
├── data/
│   └── mock_data.dart           # Provider & agent data
├── models/
│   └── models.dart              # Data models
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── ai_processing_screen.dart
│   ├── provider_recommendation_screen.dart
│   ├── agent_workflow_screen.dart
│   ├── booking_simulation_screen.dart
│   ├── followup_screen.dart
│   ├── notification_screen.dart
│   └── profile_screen.dart
└── widgets/
    ├── common_widgets.dart
    ├── provider_card.dart
    ├── agent_node.dart
    └── bottom_nav.dart
```

## 📄 License

MIT License — feel free to use and modify.

---

Built with ❤️ for hackathons and demo days.
