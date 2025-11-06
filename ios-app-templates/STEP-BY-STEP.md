# 📱 iOS App Setup - Visual Step-by-Step Guide

Follow these steps exactly to create your iOS app in 15 minutes!

---

## 🎯 Step 1: Create Xcode Project (3 minutes)

### 1️⃣ Open Xcode
```
Applications → Xcode → Open
```

### 2️⃣ Create New Project
```
Click: "Create a new Xcode project"
or
File → New → Project
```

### 3️⃣ Choose Template
```
Select: iOS
Then: App
Click: Next
```

### 4️⃣ Configure Project
```
Product Name:             PlanMyDay
Team:                     [Your Team or None]
Organization Identifier:  com.yourname.planmyday
Interface:                ⚠️ Storyboard (NOT SwiftUI!)
Language:                 Swift

Click: Next
```

### 5️⃣ Save Project
```
Choose a location: (anywhere except Rails project)
Click: Create
```

✅ **You now have an empty iOS project!**

---

## 📦 Step 2: Add Hotwire Native (2 minutes)

### 1️⃣ Add Package
```
File → Add Package Dependencies...
```

### 2️⃣ Paste URL
```
In search field, paste:
https://github.com/hotwired/hotwire-native-ios

Press Enter
```

### 3️⃣ Add Package
```
Click: "Add Package" (top right)
Wait for it to load...
```

### 4️⃣ Confirm Selection
```
Ensure these are checked:
☑️ HotwireNative
☑️ PlanMyDay (your target)

Click: "Add Package"
```

✅ **Hotwire Native is now installed!**

---

## ⚙️ Step 3: Configure Info.plist (2 minutes)

### 1️⃣ Open Info.plist
```
In Project Navigator (left sidebar):
Click: Info.plist
```

### 2️⃣ Remove Storyboard
```
Find: "Application Scene Manifest"
Expand: "Scene Configuration"
Expand: "Application Session Role"
Expand: "Item 0"

Right-click on: "Storyboard Name"
Click: Delete Row
```

### 3️⃣ Allow Localhost (Development Only)
```
Right-click anywhere in Info.plist
Click: "Add Row"

Type: "App Transport Security Settings"
(it will autocomplete)

Click the ▶️ to expand it
Click the + to add a child

Type: "Allow Arbitrary Loads"
Value: YES (toggle to YES)
```

⚠️ **Remove this for production!**

✅ **Info.plist configured!**

---

## 📝 Step 4: Add Template Files (5 minutes)

### 1️⃣ Replace AppDelegate.swift
```
In Project Navigator:
Click: AppDelegate.swift

Select ALL the code (Cmd+A)
Delete it (Backspace)

Open: ios-app-templates/AppDelegate.swift
Copy ALL the code (Cmd+A, Cmd+C)

Back in Xcode:
Paste (Cmd+V)
Save (Cmd+S)
```

### 2️⃣ Replace SceneDelegate.swift
```
In Project Navigator:
Click: SceneDelegate.swift

Select ALL (Cmd+A)
Delete (Backspace)

Open: ios-app-templates/SceneDelegate.swift
Copy ALL (Cmd+A, Cmd+C)

Back in Xcode:
Paste (Cmd+V)
Save (Cmd+S)
```

### 3️⃣ Create Configuration.swift
```
In Project Navigator:
Right-click on "PlanMyDay" folder
Click: New File...
Choose: Swift File
Name it: Configuration
Click: Create

Open: ios-app-templates/Configuration.swift
Copy ALL (Cmd+A, Cmd+C)

Back in Xcode (in the new empty file):
Paste (Cmd+V)
Save (Cmd+S)
```

### 4️⃣ Create PushNotificationManager.swift
```
In Project Navigator:
Right-click on "PlanMyDay" folder
Click: New File...
Choose: Swift File
Name it: PushNotificationManager
Click: Create

Open: ios-app-templates/PushNotificationManager.swift
Copy ALL (Cmd+A, Cmd+C)

Back in Xcode:
Paste (Cmd+V)
Save (Cmd+S)
```

✅ **All files added!**

---

## 🚀 Step 5: Test The App! (3 minutes)

### 1️⃣ Start Rails Server
```bash
Open Terminal
cd /Users/jonathanbuckland/projects/planmyday
bin/dev
```

### 2️⃣ Verify Rails is Running
```
Open browser:
http://localhost:3000

Should see your homepage!
```

### 3️⃣ Select Simulator
```
In Xcode, top toolbar:
Click the device dropdown (next to "PlanMyDay")
Choose: iPhone 15 (or any iPhone)
```

### 4️⃣ Build and Run
```
Click: ▶️ Play button (top left)
or
Press: Cmd+R

Wait for build...
Simulator will open...
```

### 5️⃣ Watch the Magic! ✨
```
Your app should load!
You'll see your Rails homepage!
```

✅ **Your iOS app is running!**

---

## ✅ Step 6: Test Features (5 minutes)

### Test Navigation
- [ ] Tap "Dashboard" in nav
- [ ] Tap "Tasks"
- [ ] Tap "Backlog"
- [ ] Back button works

### Test Authentication
- [ ] Tap "Sign Up"
- [ ] Fill out form
- [ ] Should open as modal!
- [ ] Create account
- [ ] Should log you in

### Test Forms
- [ ] Add a new task
- [ ] Should open as modal!
- [ ] Fill out form
- [ ] Submit
- [ ] Should close modal and show task

### Test Pull-to-Refresh
- [ ] On dashboard, pull down from top
- [ ] Should refresh content

### Check Console Logs
```
In Xcode, bottom panel (Cmd+Shift+Y to show):
Look for:
✅ "Path configuration loaded"
✅ "Navigator started"
❌ No errors in red
```

✅ **Everything works!**

---

## 🎉 Success!

You now have a native iOS app running your Rails backend!

### What Just Happened?

1. 📱 Created native iOS app shell
2. 📦 Added Hotwire Native framework
3. ⚙️ Configured for localhost development
4. 📝 Added Swift files for navigation
5. 🚀 Launched app in simulator
6. ✨ Your Rails app runs in native iOS!

### What's Next?

**For Development:**
- Keep Rails running: `bin/dev`
- Make changes to Rails views/controllers
- Refresh in simulator (pull down or Cmd+R)
- Changes appear instantly!

**For Production:**
1. Update `Configuration.swift` to production URL
2. Remove "Allow Arbitrary Loads" from Info.plist
3. Add app icon
4. Submit to App Store

### Need Help?

- **Troubleshooting:** See `iOS-SETUP-GUIDE.md`
- **Rails Backend:** See `../CLAUDE.md`
- **Hotwire Docs:** https://native.hotwired.dev/

---

## 🐛 Quick Troubleshooting

### Problem: Xcode can't find HotwireNative
```
Solution:
File → Add Package Dependencies
Re-add: https://github.com/hotwired/hotwire-native-ios
```

### Problem: Build errors
```
Solution:
Product → Clean Build Folder (Shift+Cmd+K)
Then: Product → Build (Cmd+B)
```

### Problem: Can't connect to localhost
```
Solution:
1. Check Rails running: bin/dev
2. Check browser works: http://localhost:3000
3. Check Info.plist has "Allow Arbitrary Loads"
```

### Problem: App loads but shows errors
```
Solution:
Check Xcode console (bottom panel)
Check Rails logs: tail -f log/development.log
```

---

## 🎊 Congratulations!

You've successfully created a native iOS app powered by your Rails backend!

**Time to celebrate:** 🎉🎊🥳

Now go show your team! 📱✨
