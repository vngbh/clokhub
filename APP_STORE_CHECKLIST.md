# App Store Submission Checklist

## 📋 Pre-Submission Requirements

### ✅ Technical Requirements

- [ ] **Info.plist** configured with all required keys
- [ ] **App Icons** - All required sizes (20x20 to 1024x1024)
- [ ] **Launch Screen** configured properly
- [ ] **Bundle Identifier** set (currently: `vngbh.clokhub`)
- [ ] **Version Numbers** set (Marketing: 1.0, Build: 1)
- [ ] **Deployment Target** iOS 16.0+
- [ ] **Code Signing** configured for Distribution

### ✅ Content Requirements

- [ ] **Privacy Policy** created and hosted
- [ ] **App Description** written (see APP_STORE_INFO.md)
- [ ] **Keywords** selected for App Store SEO
- [ ] **Screenshots** captured for all device sizes:
  - [ ] iPhone 6.7" (iPhone 15 Pro Max)
  - [ ] iPhone 6.1" (iPhone 15 Pro)
  - [ ] iPhone 5.5" (iPhone 8 Plus)
  - [ ] iPad Pro 12.9" (6th generation)
  - [ ] iPad Pro 12.9" (2nd generation)

### ✅ Apple Developer Account

- [ ] **Active Developer Account** ($99/year)
- [ ] **Distribution Certificate** created
- [ ] **App Store Provisioning Profile** created
- [ ] **App Store Connect** app record created

### ✅ Testing & Quality

- [ ] **TestFlight** beta testing completed
- [ ] **Device Testing** on multiple iOS versions
- [ ] **Memory Leaks** checked with Instruments
- [ ] **Crash Testing** - app stable under normal use
- [ ] **Accessibility** - VoiceOver support tested

### ✅ App Store Connect Setup

- [ ] **App Information** completed
- [ ] **Pricing** set (Free or Paid)
- [ ] **App Privacy** questions answered
- [ ] **Review Information** provided
- [ ] **App Review Screenshots** uploaded
- [ ] **App Preview Videos** (optional but recommended)

## 🚀 Deployment Steps

### 1. Final Build Preparation

```bash
# Clean build
rm -rf ~/Library/Developer/Xcode/DerivedData/clokhub-*
```

### 2. Archive for Distribution

1. Open Xcode
2. Select "Any iOS Device" as destination
3. Product → Archive
4. Organizer → Distribute App
5. App Store Connect → Upload

### 3. App Store Connect Submission

1. Select uploaded build
2. Complete app information
3. Submit for Review

### 4. Review Process

- **Review Time**: 1-7 days typically
- **Common Rejections**:
  - Missing privacy policy
  - App crashes on launch
  - Incomplete app information
  - Violating design guidelines

## 📝 Post-Launch Tasks

- [ ] **Monitor Reviews** and respond to user feedback
- [ ] **Track Analytics** via App Store Connect
- [ ] **Plan Updates** based on user feedback
- [ ] **Marketing Activities** if desired

## 🔗 Useful Links

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [TestFlight Beta Testing](https://developer.apple.com/testflight/)

## ⚠️ Important Notes

1. **Privacy Policy is MANDATORY** - must be accessible via URL
2. **Test thoroughly** - rejections delay launch by weeks
3. **Follow design guidelines** - consistent with iOS patterns
4. **Prepare for questions** - Apple may request additional info
5. **Be patient** - first submission often has feedback
