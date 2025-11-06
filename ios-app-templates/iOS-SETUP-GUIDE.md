# PlanMyDay iOS App Setup Guide

This guide will walk you through creating the iOS app for PlanMyDay using Hotwire Native.

## Prerequisites

- macOS with Xcode 15+ installed
- PlanMyDay Rails app running (already done ✓)
- iOS 14+ target device or simulator

## Part 1: Create the Xcode Project

### Step 1: Create New Project in Xcode

1. Open Xcode
2. Click **"Create a new Xcode project"** (or File → New → Project)
3. Choose **iOS** → **App**
4. Click **Next**

### Step 2: Configure Project Settings

- **Product Name:** `PlanMyDay`
- **Team:** Select your Apple Developer Team (or None for simulator only)
- **Organization Identifier:** `com.yourname.planmyday` (use your own identifier)
- **Bundle Identifier:** Will be auto-generated (e.g., `com.yourname.planmyday.PlanMyDay`)
- **Interface:** Select **Storyboard** (NOT SwiftUI)
- **Language:** Swift
- **Storage:** None
- **Include Tests:** ✓ (optional but recommended)

### Step 3: Choose Save Location

- Save the project anywhere you like (e.g., Desktop or a projects folder)
- **DO NOT** save inside the Rails project directory
- Click **Create**

## Part 2: Add Hotwire Native Package

### Step 1: Add Package Dependency

1. In Xcode, go to **File → Add Package Dependencies...**
2. In the search field (top right), paste:
   ```
   https://github.com/hotwired/hotwire-native-ios
   ```
3. Click **Add Package**
4. In the "Choose Package Products" dialog:
   - Ensure **HotwireNative** is selected
   - Ensure your app target (**PlanMyDay**) is selected
5. Click **Add Package**

Wait for Xcode to download and integrate the package.

## Part 3: Configure the App

### Step 1: Update Info.plist

1. In the Project Navigator (left sidebar), click on **Info.plist**
2. Find the row **"Application Scene Manifest"**
3. Expand it → Expand **"Scene Configuration"** → Expand **"Application Session Role"** → Expand **"Item 0"**
4. **DELETE** the row that says **"Storyboard Name"** (right-click → Delete Row)
5. Still in Info.plist, add a new row for development (localhost access):
   - Right-click anywhere → **Add Row**
   - Key: **"App Transport Security Settings"** (it will autocomplete)
   - Expand it, add a new child row:
   - Key: **"Allow Arbitrary Loads"** → Value: **YES**

   ⚠️ **Note:** Remove this in production! Only for development.

### Step 2: Replace SceneDelegate.swift

1. In the Project Navigator, find and click **SceneDelegate.swift**
2. **Replace ALL the contents** with the template from `SceneDelegate.swift` (in this folder)

### Step 3: Replace AppDelegate.swift

1. In the Project Navigator, find and click **AppDelegate.swift**
2. **Replace ALL the contents** with the template from `AppDelegate.swift` (in this folder)

### Step 4: Add Configuration File

1. Right-click on the **PlanMyDay** folder in Project Navigator
2. Select **New File...**
3. Choose **Swift File**
4. Name it **`Configuration.swift`**
5. Click **Create**
6. Copy the contents from the template `Configuration.swift` (in this folder)

## Part 4: Test the App

### Step 1: Start Your Rails Server

Make sure your Rails app is running:
```bash
cd /Users/jonathanbuckland/projects/planmyday
bin/dev
```

Verify it's accessible at: http://localhost:3000

### Step 2: Run in Simulator

1. In Xcode, select a simulator from the device dropdown (e.g., **iPhone 15**)
2. Click the **Play button** (▶️) or press **Cmd+R**
3. Wait for the app to build and launch

### Step 3: Test Basic Functionality

The app should load your Rails homepage. Test:
- [ ] App loads the homepage
- [ ] Navigation works (tap Dashboard, Tasks, etc.)
- [ ] Can sign up / log in
- [ ] Forms work (create a task)
- [ ] Modal presentation works for `/tasks/new`
- [ ] Pull-to-refresh works on dashboard

## Part 5: Add Push Notifications Support (Optional)

### Step 1: Enable Capability

1. In Xcode, select the **PlanMyDay** project in Navigator
2. Select the **PlanMyDay** target
3. Click the **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for and add **"Push Notifications"**

### Step 2: Add Notification Code

1. Create a new file: **`PushNotificationManager.swift`**
2. Copy contents from template `PushNotificationManager.swift` (in this folder)
3. This will register for push notifications and send the device token to your Rails API

## Part 6: Customize App Icons and Launch Screen

### App Icon

1. In Assets.xcassets, click **AppIcon**
2. Drag and drop your app icons (you'll need various sizes)
3. Tool to generate all sizes: https://appicon.co/

### Launch Screen

1. Click **LaunchScreen.storyboard** in Project Navigator
2. Customize with your branding (or use the default)
3. Keep it simple - it only shows for a moment

## Troubleshooting

### Problem: "Failed to load path configuration"

**Solution:** Make sure your Rails server is running and accessible at the URL in `Configuration.swift`

### Problem: "Cannot connect to localhost"

**Solution:**
- Check Rails is running: `curl http://localhost:3000`
- Verify Info.plist allows localhost connections (Step 3.1 above)
- Try the iOS simulator (not a physical device for localhost)

### Problem: Authentication doesn't work

**Solution:**
- Check cookies are enabled
- Verify `/session/new` loads correctly
- Check Rails logs for authentication errors

### Problem: Modal presentation doesn't work

**Solution:**
- Verify path configuration is loading: Check Xcode console logs
- Test the endpoint: `curl http://localhost:3000/path-configuration.json`
- Check pattern matching in `HotwireNativeController`

### Problem: Build errors with Hotwire Native

**Solution:**
- Update to latest Xcode
- Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)
- Delete derived data: Xcode → Preferences → Locations → Derived Data → Delete

## Testing on a Physical Device

### Development Setup

1. Connect your iPhone via USB
2. Select your iPhone from the device dropdown
3. Click Run
4. You'll need to change the Rails URL from `localhost` to your Mac's IP address
   - Find your IP: System Preferences → Network
   - Update `Configuration.swift`: `http://YOUR_IP:3000`

### Production Setup

1. Deploy your Rails app to Fly.io (already done ✓)
2. Update `Configuration.swift` to use production URL:
   ```swift
   static let serverURL = URL(string: "https://planmyday-app.fly.dev")!
   ```
3. Remove "Allow Arbitrary Loads" from Info.plist (Step 3.1)
4. Build and run

## Next Steps

Once the iOS app is working:

1. **Test thoroughly** on different iOS versions
2. **Add app icon** and launch screen
3. **Configure signing** for TestFlight/App Store
4. **Submit to TestFlight** for beta testing
5. **Submit to App Store** for public release

## Resources

- [Hotwire Native iOS Docs](https://native.hotwired.dev/ios)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)
- [Xcode Documentation](https://developer.apple.com/documentation/xcode)

## Getting Help

If you encounter issues:
1. Check Xcode console logs for errors
2. Check Rails server logs: `tail -f log/development.log`
3. Review Hotwire Native documentation
4. Check the GitHub Issues: https://github.com/hotwired/hotwire-native-ios/issues
