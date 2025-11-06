# PlanMyDay iOS App Templates

This folder contains everything you need to create the PlanMyDay iOS app using Hotwire Native.

## 📁 What's Inside

### Documentation
- **iOS-SETUP-GUIDE.md** - Complete step-by-step setup guide
- **QUICKSTART-CHECKLIST.md** - Quick checklist for fast setup
- **README.md** - This file

### Swift Templates
- **Configuration.swift** - App configuration (server URLs, features)
- **AppDelegate.swift** - App delegate with Hotwire setup
- **SceneDelegate.swift** - Scene delegate with Navigator
- **PushNotificationManager.swift** - Push notification handling

## 🚀 Getting Started

### Quick Start (15 minutes)

1. **Follow the checklist:**
   ```bash
   open QUICKSTART-CHECKLIST.md
   ```

2. **Create Xcode project** (5 minutes)
   - New iOS App with Storyboard interface
   - Add Hotwire Native package

3. **Copy template files** (5 minutes)
   - Replace AppDelegate.swift
   - Replace SceneDelegate.swift
   - Add Configuration.swift
   - Add PushNotificationManager.swift

4. **Test it** (5 minutes)
   - Start Rails: `bin/dev`
   - Run in simulator
   - Your app should work!

### Detailed Setup (30-45 minutes)

For comprehensive instructions including troubleshooting:
```bash
open iOS-SETUP-GUIDE.md
```

## 🎯 What You'll Build

A native iOS app that:
- ✅ Wraps your Rails web app
- ✅ Native navigation and modals
- ✅ Pull-to-refresh
- ✅ Cookie-based authentication (works automatically!)
- ✅ Push notifications support
- ✅ Feels like a native app

## 📋 Prerequisites

- macOS with Xcode 15+
- Rails app running at http://localhost:3000
- Basic familiarity with Xcode (we'll guide you!)

## 💡 How It Works

### Hotwire Native Architecture

```
┌─────────────────────────────────┐
│      iOS Native Shell           │
│  (Navigation, Modals, Native)   │
│                                 │
│   ┌─────────────────────────┐  │
│   │    WKWebView            │  │
│   │  (Your Rails App)       │  │
│   │                         │  │
│   │  - Turbo Drive          │  │
│   │  - Stimulus             │  │
│   │  - Regular HTML/CSS     │  │
│   └─────────────────────────┘  │
│                                 │
│   Path Configuration            │
│   (Defines modals, etc.)        │
└─────────────────────────────────┘
         ↕️
┌─────────────────────────────────┐
│    Rails Backend (You!)         │
│  - Serves HTML                  │
│  - Path config JSON             │
│  - Authentication               │
│  - Push notification API        │
└─────────────────────────────────┘
```

### Key Concepts

1. **Single Codebase** - Your Rails app serves iOS, Android, and web
2. **Native Navigation** - iOS handles navigation, back buttons, modals
3. **Path Configuration** - JSON file tells iOS how to present each route
4. **Bridge Components** - Add native features when needed (optional)

## 🔧 Customization

### Change Server URL

Edit `Configuration.swift`:
```swift
// Development
static let serverURL = URL(string: "http://localhost:3000")!

// Production
static let serverURL = URL(string: "https://planmyday-app.fly.dev")!
```

### Modify Path Configuration

Your Rails app controls routing behavior via:
```
app/controllers/hotwire_native_controller.rb
```

No Xcode changes needed!

### Enable/Disable Features

Edit `Configuration.swift`:
```swift
static let enablePushNotifications = true
static let enableDebugLogging = true
```

## 📱 Testing

### Local Testing
- Rails: `http://localhost:3000`
- Xcode: iPhone Simulator
- Fast iteration, instant changes

### Device Testing
- Connect iPhone via USB
- Update Configuration.swift to use Mac's IP
- Test on real hardware

### Production Testing
- Point to production URL
- Upload to TestFlight
- Beta test with real users

## 🎨 App Branding

### App Icon
1. Generate icons: https://appicon.co/
2. In Xcode: Assets.xcassets → AppIcon
3. Drag and drop generated icons

### Launch Screen
1. Click LaunchScreen.storyboard
2. Customize with your branding
3. Keep it simple (shows briefly)

### Display Name
1. Select project in Navigator
2. General tab → Display Name
3. Change from "PlanMyDay" if desired

## 🐛 Troubleshooting

See **iOS-SETUP-GUIDE.md** for detailed troubleshooting section.

Common issues:
- Can't connect to localhost → Check Rails is running
- Build errors → Clean build folder (Shift+Cmd+K)
- Path config not loading → Test endpoint with curl

## 📚 Learn More

- [Hotwire Native Docs](https://native.hotwired.dev/ios)
- [Apple Developer Docs](https://developer.apple.com/documentation/)
- [Your Rails CLAUDE.md](../CLAUDE.md) - Has full backend documentation

## 🚢 Deployment

Ready to ship to the App Store?

1. Complete app setup (icons, launch screen)
2. Configure signing & provisioning
3. Archive the app
4. Upload to App Store Connect
5. Submit for review

See Apple's App Store submission guidelines.

## 🎉 That's It!

You now have everything needed to build the iOS app. Follow the QUICKSTART-CHECKLIST.md and you'll have a running app in 15 minutes!

Questions? Check the detailed guide or the Rails CLAUDE.md documentation.
