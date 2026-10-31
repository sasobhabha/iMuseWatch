# iMuseWatch for Apple Watch (watchOS)

An independent, standalone Apple Watch companion app for your personal Muse AI. Wear your companion on your wrist with edge-to-edge OLED black design, full voice interaction (hold-to-talk / tap-to-talk), spoken replies via Text-to-Speech, tactile haptics, glanceable notifications, and live transcripts.

---

## Highlights

- **Pure OLED Black Design (`#000000`):** Edge-to-edge borderless display tuned for Apple Watch OLED and microLED screens.
- **Living Companion Avatar:**
  - Procedural vector mascot with dynamic breathing/bobbing animations, eye blinks, smiling/speaking mouth, and blushing cheeks.
  - Optional official Jolly Avatar graphic mode.
  - Interactive mood reactions: `idle`, `thoughtful`, `cheerful`, `concerned`, `listening`, and `speaking`.
- **Wearable Voice Gestures:**
  - **Hold-to-Talk:** Press and hold the avatar to record your voice; release to send.
  - **Tap-to-Talk:** Tap the avatar to toggle voice capture mode.
  - Visual pulse ring glows and expands while listening.
- **Spoken Audio by Default:** Replies are read aloud using Apple Watch's native `AVSpeechSynthesizer` through the speaker or connected Bluetooth AirPods.
- **Subtitles & Captions:** Subtle on-screen subtitle pill displays current transcript or companion response in real time.
- **Live Transcript Sheet:** Full conversation history scrollable with the Digital Crown.
- **Glanceable Updates:** Receive proactive update cards (`puck.update`) and confirmations.
- **Digital Crown Scaling:** Rotating the Digital Crown smoothly scales the avatar with tactile detents.
- **Private & Secure:** Credentials and personal SDK tokens are kept strictly in Apple Watch Keychain with zero telemetry.

---

## Architecture & Code Structure

```
iMuseWatch/
├── iMuseWatch.xcodeproj/         # Xcode project generated via xcodegen
├── project.yml                   # Declarative Xcode project definition
├── iMuseWatch/
│   ├── iMuseWatchApp.swift       # watchOS App entry point (@main)
│   ├── Info.plist                # Permissions (Microphone, Audio) & Watch-only flag
│   ├── Models/
│   │   ├── ApplianceState.swift  # ApplianceStatus and ConnectionStatus enums
│   │   ├── CompanionMood.swift   # Companion moods and glow colors
│   │   ├── MuseMessage.swift     # Message and notification data structures
│   │   └── WorkspaceRequest.swift# Action cards and confirmation commands
│   ├── Services/
│   │   ├── MuseRuntime.swift     # MainActor state coordinator
│   │   ├── MuseClient.swift      # REST/WebSocket communication & mock engine
│   │   ├── AudioRecorder.swift   # 16kHz WAV voice capture via AVFoundation
│   │   ├── SpeechManager.swift   # Spoken voice synthesis via AVSpeechSynthesizer
│   │   ├── HapticManager.swift   # Tactile Taptic feedback via WKInterfaceDevice
│   │   └── KeychainVault.swift   # Secure Apple Watch Keychain storage
│   ├── Views/
│   │   ├── ContentView.swift     # Root watch face with top bar, avatar, and captions
│   │   ├── AvatarView.swift      # Interactive procedural & image avatar
│   │   ├── CaptionsOverlayView.swift # Subtitle banner
│   │   ├── TranscriptView.swift  # Scrollable chat transcript sheet
│   │   ├── NotificationsView.swift # Glanceable update card
│   │   ├── SettingsView.swift    # Voice rate, display options, and SDK token
│   │   └── SetupView.swift       # First-launch onboarding guide
│   └── Assets.xcassets/          # AppIcon, JollyAvatar, AccentColor
├── iMuseWatchTests/
│   └── iMuseWatchTests.swift     # Unit tests for token validation, status, and logic
└── scripts/
    └── build-watch.sh            # Automated build and test runner
```

---

## Building and Running

### Prerequisites

- macOS with Xcode 15+ (tested with Xcode 27 on watchOS 10+ / 27 SDK)
- `xcodegen` (`brew install xcodegen`)

### Build & Run from Command Line

```bash
# Build the watchOS app and execute all unit tests:
./scripts/build-watch.sh
```

### Run in Xcode

1. Open `iMuseWatch.xcodeproj` in Xcode.
2. Select the **iMuseWatch** scheme.
3. Choose an Apple Watch Simulator destination (e.g., **Apple Watch Series 12 (46mm)** or **Apple Watch Ultra**).
4. Press `Cmd + R` to run.

---

## Setting Up Your Personal Muse Token

1. Generate your personal SDK token at [gadgets.muse.ai/settings/sdk-tokens](https://gadgets.muse.ai/settings/sdk-tokens).
2. On your Apple Watch, tap the **Gear icon** in the top-left corner to open **Settings**.
3. Tap **Edit SDK Token** and enter your token (e.g., `mgst_...`).
4. Without a token, iMuseWatch operates in intelligent **on-device companion mode** for immediate offline testing.
