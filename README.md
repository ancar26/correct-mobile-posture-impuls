# PostureGuard

A lightweight iOS app that quietly watches your posture while you scroll, text, or browse — and nudges you before your neck pays the price.

## What it does

Most posture apps ask you to wear something or set a timer. PostureGuard just uses the phone you're already holding. It watches how you're holding it (phone tilt via the accelerometer) and how you're looking at it (face angle + shoulder line via the front camera), then fires an alert if you've been hunched for too long.

The flow is simple:

1. **Calibrate once** — hold your phone at a comfortable, upright position and tap Calibrate. That's your baseline.
2. **Switch to any other app** — PostureGuard keeps running in the background.
3. **Get a warning** — if your posture drifts for more than ~12 seconds, a banner appears. After that, a full-screen alert fires (plus a push notification if you're in another app).
4. **Tap to dismiss** — the timer resets and you carry on.

Smart enough to ignore the phone sitting on your desk or in your pocket — it only tracks when you're actively holding it.

## Tech stack

- **Swift + SwiftUI** — the whole UI layer
- **Vision** (`VNDetectFaceRectanglesRequest`, `VNDetectHumanBodyPoseRequest`) — reads face pitch/yaw and shoulder slope from front camera frames
- **CoreMotion** — phone pitch angle and a rolling acceleration variance to detect whether the phone is actually being held
- **AVFoundation** — front camera session feeding frames into Vision
- **UserNotifications** — background push alert when posture goes bad while you're in another app
- **UserDefaults** — persists your calibration baseline across launches
- **XcodeGen** (`project.yml`) — project file is generated, so no messy `.pbxproj` conflicts in git

## Project structure

```
Sources/PostureGuard/
├── App/
│   ├── PostureGuardApp.swift       entry point
│   └── NotificationManager.swift  push notification setup + sending
├── Detection/
│   ├── PostureDetectionManager.swift   orchestrates camera + motion, owns the status state machine
│   ├── CameraManager.swift             AVFoundation session + Vision requests
│   └── MotionManager.swift             CoreMotion pitch + held-detection
├── Models/
│   └── PostureStatus.swift         status enum, baseline + reading structs, bad-posture scoring
└── Views/
    ├── ContentView.swift           root view, wires everything together
    ├── CameraPreviewView.swift     live camera preview (used during calibration)
    ├── PostureAlertOverlay.swift   full-screen bad posture alert
    └── Onboarding/                 welcome → instructions → calibration → done
```

## How the detection works

PostureGuard scores each reading on three signals and flags bad posture when the combined score hits 2+:

| Signal | How it's measured | Score |
|---|---|---|
| Phone tilt | Pitch dropped >25° from baseline | +2 (>12° → +1) |
| Face pitch | Head dropped >0.25 rad from baseline | +2 (>0.12 → +1) |
| Shoulder slope | Y-difference between shoulders >0.08 | +1 |

The phone-held check uses acceleration variance over a 4-second window — if the phone is sitting still on a table, detection pauses silently. There's also a 3-second grace period right after you pick the phone up.

## Getting started

Requirements: Xcode 15+, iOS 16+, a physical device (camera + motion don't work in Simulator).

```bash
# Generate the Xcode project from project.yml
brew install xcodegen
xcodegen generate

# Then open PostureGuard.xcodeproj and run on a device
```

Or run the included setup script:

```bash
./setup.sh
```

## Permissions

The app will ask for:
- **Camera** — front camera only, frames are processed on-device and never stored or sent anywhere
- **Notifications** — for background alerts when you're in another app
