# iOS App Quick Start Checklist

Follow these steps to get your PlanMyDay iOS app running!

## ✅ Checklist

### Part 1: Xcode Project Setup
- [ ] Open Xcode
- [ ] Create new iOS App project
- [ ] Name it "PlanMyDay"
- [ ] Select **Storyboard** interface (NOT SwiftUI)
- [ ] Save project (anywhere except inside Rails directory)

### Part 2: Add Hotwire Native
- [ ] File → Add Package Dependencies
- [ ] Add: `https://github.com/hotwired/hotwire-native-ios`
- [ ] Select HotwireNative package
- [ ] Wait for package to download

### Part 3: Configure Project
- [ ] Open Info.plist
- [ ] Delete "Storyboard Name" row (under Scene Configuration)
- [ ] Add "App Transport Security Settings" → "Allow Arbitrary Loads" = YES

### Part 4: Add Template Files
- [ ] Replace **AppDelegate.swift** with template
- [ ] Replace **SceneDelegate.swift** with template
- [ ] Create new file **Configuration.swift** with template
- [ ] Create new file **PushNotificationManager.swift** with template

### Part 5: Test It!
- [ ] Start Rails server: `bin/dev`
- [ ] Verify: http://localhost:3000 works
- [ ] Select iPhone simulator in Xcode
- [ ] Click Run (▶️)
- [ ] App should load your Rails homepage!

### Part 6: Test Features
- [ ] Navigation works (tap links)
- [ ] Login/signup works
- [ ] Forms work (create a task)
- [ ] Modals open for /tasks/new
- [ ] Pull-to-refresh works on dashboard

## 🎉 Success Criteria

Your app is working when:
1. ✅ Simulator shows your Rails homepage
2. ✅ You can navigate between pages
3. ✅ You can log in
4. ✅ Task creation opens as a modal
5. ✅ Pull-to-refresh reloads content

## 🐛 Common Issues

### "Cannot connect to localhost"
- Make sure Rails is running: `bin/dev`
- Check Info.plist has "Allow Arbitrary Loads"
- Use iOS Simulator (not physical device for localhost)

### "Failed to load path configuration"
- Test endpoint: `curl http://localhost:3000/path-configuration.json`
- Should return JSON with path rules

### Build errors
- Clean build: Shift+Cmd+K
- Restart Xcode
- Delete derived data

## 📱 Testing on Your iPhone

Want to test on your actual iPhone?

1. Connect iPhone via USB
2. Select your iPhone in Xcode
3. Update Configuration.swift:
   - Find your Mac's IP: System Preferences → Network
   - Change: `http://YOUR_MAC_IP:3000`
4. Click Run

## 🚀 Production Deployment

Ready to deploy?

1. Update Configuration.swift:
   ```swift
   static let serverURL = URL(string: "https://planmyday-app.fly.dev")!
   ```
2. Remove "Allow Arbitrary Loads" from Info.plist
3. Add app icons to Assets.xcassets
4. Configure signing & certificates
5. Archive and upload to TestFlight

## 📚 Full Documentation

See **iOS-SETUP-GUIDE.md** for detailed instructions!
