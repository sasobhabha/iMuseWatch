# iMuseWatch

An open source, standalone **Apple Watch (watchOS)** companion and wearable AI appliance for your personal Muse. Turn your Apple Watch into a dedicated, living **Muse Charm**: tap or hold your avatar to talk, experience spoken replies aloud, feel tactile haptic feedback, and view glanceable notifications on a borderless, pure OLED black watch face.

---

## What Works

- **Authentic Muse Charm Aesthetic:** The living avatar floats centered edge-to-edge against pure OLED black (`#000000`), borderless and matching the rounded contour of Apple Watch displays.
- **Living Vector Companion:** Smooth 60fps breathing, blinking, smiling, and speaking procedural animations that reflect your companion's mood (`idle`, `thoughtful`, `cheerful`, `concerned`, `listening`, `speaking`).
- **Jolly Avatar Mascot Option:** Toggle between the procedural vector mascot and the official graphic avatar directly in Settings.
- **Wearable Voice Gestures:**
  - **Hold-to-Talk:** Press down on your companion to start recording voice; release to send immediately to Muse.
  - **Tap-to-Talk:** Tap the avatar face to toggle voice recording on and off.
  - Ambient glowing pulse ring responds to your voice input.
- **Spoken Voice by Default:** Spoken replies are read aloud via watchOS native Text-to-Speech (`AVSpeechSynthesizer`) directly from the Apple Watch speaker or connected AirPods.
- **Subtitles & Live Captions:** Floating subtitle cards display the spoken dialogue; tap to open the full conversation transcript.
- **Digital Crown Support:** Rotate the Digital Crown to scale your companion or scroll smoothly through conversation history with subtle tactile detents.
- **Proactive Glanceable Updates:** Proactive notifications (`puck.update`) and task cards appear cleanly at the top of the watch face.
- **On-Device Keychain Security:** Personal Muse SDK tokens (`mgst_...`) and VM keys are kept securely inside the Apple Watch Keychain with zero telemetry.
- **Standalone On-Device Mode:** Works immediately out of the box in interactive companion mode even before entering an SDK token.

---

## Quick Start

### 1. Build and Test via CLI

```bash
./scripts/build-watch.sh
```

### 2. Open in Xcode

1. Open `iMuseWatch.xcodeproj` in Xcode (requires Xcode 15+).
2. Select the **iMuseWatch** scheme.
3. Select any watchOS Simulator (such as **Apple Watch Series 12 (46mm)**, **Apple Watch Ultra**, or your paired physical Apple Watch).
4. Press `Cmd + R` to run!

---

## Connecting Your Muse Account

> [!IMPORTANT]
> **Your Muse SDK token MUST be your own.**  
> Generate your personal token from your account at [gadgets.muse.ai/settings/sdk-tokens](https://gadgets.muse.ai/settings/sdk-tokens).  
> - Never share or commit tokens.  
> - In iMuseWatch on your Apple Watch, tap the **Gear icon** in the top-left corner -> **Edit SDK Token** -> enter your `mgst_...` token.  
> - Tokens are stored securely in your watch's hardware-backed Keychain.

---

## Project Structure

```
iMuseWatch/
├── iMuseWatch.xcodeproj/          # Native Xcode Project (generated via xcodegen)
├── project.yml                    # XcodeGen project specification
├── iMuseWatch/
│   ├── iMuseWatchApp.swift        # Main watchOS App entry point (@main)
│   ├── Info.plist                 # watchOS permissions & standalone WKWatchOnly configuration
│   ├── Models/
│   │   ├── ApplianceState.swift   # Status & connection state definitions
│   │   ├── CompanionMood.swift    # Mood states & glow colors
│   │   ├── MuseMessage.swift      # Messages & glanceable notifications
│   │   └── WorkspaceRequest.swift # Workspace requests & confirmation cards
│   ├── Services/
│   │   ├── MuseRuntime.swift      # MainActor observable state engine
│   │   ├── MuseClient.swift       # Direct API client & offline companion engine
│   │   ├── AudioRecorder.swift    # 16kHz WAV voice recording
│   │   ├── SpeechManager.swift    # watchOS AVSpeechSynthesizer voice output
│   │   ├── HapticManager.swift    # Taptic Engine haptics
│   │   └── KeychainVault.swift    # Apple Keychain storage
│   ├── Views/
│   │   ├── ContentView.swift      # Main OLED black watch face & Crown controls
│   │   ├── AvatarView.swift       # Living procedural & graphical mascot
│   │   ├── CaptionsOverlayView.swift # Subtitle pill
│   │   ├── TranscriptView.swift   # Live conversation transcript sheet
│   │   ├── NotificationsView.swift# Glanceable update card
│   │   ├── SettingsView.swift     # Token setup, voice rate, and preferences
│   │   └── SetupView.swift        # First-launch onboarding
│   └── Assets.xcassets/           # AppIcon, JollyAvatar, AccentColor
├── iMuseWatchTests/
│   └── iMuseWatchTests.swift      # Full test suite for tokens, states, and client
├── docs/
│   └── APPLE_WATCH.md             # In-depth watchOS technical guide
└── scripts/
    └── build-watch.sh             # One-command build and test runner
```

---

## Migration from Android

The original Android / Unisoc SC8541E implementation files have been organized under `android_legacy/` for archival reference. The project root is now dedicated to the modern native watchOS experience for Apple Watch.
