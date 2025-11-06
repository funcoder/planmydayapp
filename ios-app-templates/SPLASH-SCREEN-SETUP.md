# 🎨 Splash Screen Setup Guide

Add a beautiful loading screen to your iOS app while content loads!

## What You're Adding

A branded loading screen that shows:
- ✨ Your app name "PlanMyDay" in teal
- 🎯 Subtitle "ADHD-Friendly Productivity"
- ⏳ Animated loading spinner
- 🌈 Subtle gradient background

---

## Step 1: Add LoadingViewController (2 minutes)

**In Xcode:**

1. Right-click on **PlanMyDay** folder (yellow folder)
2. Click **New File...**
3. Choose **Swift File**
4. Name it: **LoadingViewController**
5. Click **Create**
6. Open: `/Users/jonathanbuckland/projects/planmyday/ios-app-templates/LoadingViewController.swift`
7. Copy ALL content (Cmd+A, Cmd+C)
8. Paste in the new empty file (Cmd+V)
9. Save (Cmd+S)

---

## Step 2: Update SceneDelegate (2 minutes)

**In Xcode:**

1. Click on **SceneDelegate.swift**
2. Select ALL (Cmd+A) and Delete
3. Open: `/Users/jonathanbuckland/projects/planmyday/ios-app-templates/SceneDelegate-with-loading.swift`
4. Copy ALL (Cmd+A, Cmd+C)
5. Paste in Xcode (Cmd+V)
6. Save (Cmd+S)

---

## Step 3: Build and Run! (1 minute)

1. **Clean Build Folder**: `Shift+Cmd+K`
2. **Build**: `Cmd+B`
3. **Run**: `Cmd+R`

---

## 🎉 What You'll See

When you launch the app:

1. **Immediately shows**: Beautiful splash screen with:
   ```
   PlanMyDay
   ADHD-Friendly Productivity

   [Spinning teal indicator]
   Loading...
   ```

2. **After 2-3 seconds**: Smooth fade to your home page

---

## 🎨 Customization Options

### Change Loading Text

Edit `LoadingViewController.swift`:

```swift
// Line 18 - App name
label.text = "Your App Name"

// Line 28 - Subtitle
label.text = "Your Tagline Here"

// Line 50 - Loading message
label.text = "Getting ready..."
```

### Change Colors

The splash screen automatically uses your brand colors from `Configuration.swift`:
- Primary color (teal) for title and spinner
- System gray for subtitle

To change, edit `Configuration.swift`:
```swift
static let primaryColor = UIColor(red: R/255, green: G/255, blue: B/255, alpha: 1.0)
```

### Add a Logo Image

If you have a logo image:

1. Add your logo to **Assets.xcassets**
2. In `LoadingViewController.swift`, uncomment and modify:

```swift
// Around line 14, replace:
private let logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(named: "YourLogoName") // Add this line
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
}()

// In setupUI(), add:
view.addSubview(logoImageView)

// Add constraints:
logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
logoImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20),
logoImageView.widthAnchor.constraint(equalToConstant: 80),
logoImageView.heightAnchor.constraint(equalToConstant: 80)
```

### Change Background Gradient

Edit the gradient colors in `LoadingViewController.swift` (line 66):

```swift
gradientLayer.colors = [
    UIColor.systemBackground.cgColor,  // Top color
    UIColor.systemBackground.cgColor,  // Middle
    UIColor.systemBackground.cgColor   // Bottom
]
```

Or remove gradient entirely by commenting out lines 63-72.

### Adjust Loading Duration

The loading screen shows until the first page loads. To add a minimum display time:

In `SceneDelegate-with-loading.swift`, modify line 107:

```swift
// Change from 0.5 to desired seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
```

---

## 🐛 Troubleshooting

### Build Errors

**Solution:**
1. Clean Build Folder: `Shift+Cmd+K`
2. Restart Xcode
3. Build again: `Cmd+B`

### Loading Screen Doesn't Show

**Check:**
1. Verify `LoadingViewController.swift` is added to target
2. Check file is in the correct folder in Xcode
3. Ensure `SceneDelegate.swift` is updated

### Loading Screen Doesn't Dismiss

**Check:**
- Your Rails server is running: `http://localhost:3000`
- Check Xcode console for errors
- The app should dismiss loading when page loads or after errors

### Splash Shows Too Long/Short

Adjust the delay in `SceneDelegate-with-loading.swift` line 107:
- Too long: Reduce from `0.5` to `0.2`
- Too short: Increase from `0.5` to `1.0`

---

## 📱 Launch Screen vs Loading Screen

**What we created:**
- ✅ **Loading Screen** - Shows while web content loads (2-3 seconds)
- Can be customized with animations and real-time updates

**Optional - Static Launch Screen:**
- Shows instantly when app icon is tapped (< 1 second)
- Must be a static image or storyboard
- More complex to set up

For most apps, the Loading Screen we created is perfect!

---

## ✅ Verification

After setup, you should see:

- [ ] Splash screen appears immediately when app launches
- [ ] Shows "PlanMyDay" in teal color
- [ ] Shows spinning activity indicator
- [ ] Smoothly fades out after 2-3 seconds
- [ ] Main app content appears

---

## 🎊 You're Done!

Your app now has a professional loading experience!

Next time the app launches, users will see your beautiful branded splash screen instead of a blank white screen while content loads.

Enjoy! 🚀
