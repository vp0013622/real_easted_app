# iOS Release Checklist for Inhabit Realties

## ✅ Pre-Release Configuration (COMPLETED)

- [x] Bundle identifier updated to `com.inhabitrealties.app`
- [x] App version updated to 1.0.0
- [x] iOS permissions added (Camera, Photo Library)
- [x] App display name set to "Inhabit Realties"
- [x] iOS build tested successfully

## 🔄 Next Steps (TO DO)

### 1. Apple Developer Account Setup
- [ ] Enroll in Apple Developer Program ($99/year)
- [ ] Access App Store Connect
- [ ] Set up team and certificates

### 2. Xcode Configuration
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Configure automatic code signing
- [ ] Select your development team
- [ ] Verify bundle identifier: `com.inhabitrealties.app`

### 3. App Store Connect Setup
- [ ] Create new app record
- [ ] Fill in app information
- [ ] Set up app metadata
- [ ] Prepare app description and keywords

### 4. Assets Preparation
- [ ] Create screenshots for all required device sizes
- [ ] Verify app icon is properly configured
- [ ] Prepare app preview videos (optional)

### 5. Build and Upload
- [ ] Archive app in Xcode
- [ ] Upload to App Store Connect
- [ ] Test with TestFlight (recommended)

### 6. App Store Submission
- [ ] Fill in all required app information
- [ ] Add screenshots and metadata
- [ ] Submit for review
- [ ] Wait for Apple's review (24-48 hours)

## 📱 Required Screenshots

- [ ] iPhone 6.7" (iPhone 14/15 Pro Max)
- [ ] iPhone 6.5" (iPhone 11/12/13 Pro Max)
- [ ] iPhone 5.5" (iPhone 8/7/6s Plus)
- [ ] iPad Pro 12.9" (6th generation)
- [ ] iPad Pro 12.9" (5th generation)

## 🔧 Quick Commands

```bash
# Clean and rebuild
flutter clean && flutter pub get

# Build for iOS (for testing)
flutter build ios --release --no-codesign

# Open in Xcode
open ios/Runner.xcworkspace
```

## 📞 Support Resources

- **Apple Developer Documentation**: https://developer.apple.com/documentation
- **App Store Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **Flutter iOS Deployment**: https://flutter.dev/docs/deployment/ios

---

**Status**: ✅ Ready for iOS release configuration
**Next Action**: Set up Apple Developer account and configure Xcode signing 