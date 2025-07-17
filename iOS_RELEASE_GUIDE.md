# iOS App Release Guide for Inhabit Realties

## Prerequisites

1. **Apple Developer Account** ($99/year)
   - Sign up at [developer.apple.com](https://developer.apple.com)
   - Enroll in the Apple Developer Program

2. **Xcode** (Latest version)
   - Download from Mac App Store
   - Ensure you have the latest iOS SDK

3. **App Store Connect Access**
   - Access to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Admin or App Manager role

## Configuration Updates (Already Done)

✅ **Bundle Identifier Updated**: `com.inhabitrealties.app`
✅ **App Version Updated**: 1.0.0
✅ **iOS Permissions Added**: Camera and Photo Library access
✅ **App Display Name**: "Inhabit Realties"

## Step-by-Step Release Process

### 1. Prepare Your App

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Build for iOS release
flutter build ios --release
```

### 2. Open Xcode and Configure Signing

1. Open your project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. In Xcode:
   - Select "Runner" project in the navigator
   - Select "Runner" target
   - Go to "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your Team (Apple Developer account)
   - Ensure Bundle Identifier matches: `com.inhabitrealties.app`

### 3. Create App Store Connect Record

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps" → "+" → "New App"
3. Fill in the details:
   - **Platform**: iOS
   - **Name**: Inhabit Realties
   - **Primary Language**: English
   - **Bundle ID**: com.inhabitrealties.app
   - **SKU**: inhabit-realties-ios (unique identifier)
   - **User Access**: Full Access

### 4. Configure App Information

In App Store Connect, fill in:

#### App Information
- **App Name**: Inhabit Realties
- **Subtitle**: We present your dreams
- **Category**: Business
- **Content Rights**: You own all rights

#### App Review Information
- **Contact Information**: Your contact details
- **Demo Account**: If your app requires login
- **Notes**: Any special instructions for reviewers

#### App Store Information
- **Keywords**: real estate, property, housing, realties
- **Description**: Write a compelling app description
- **What's New**: First release features

### 5. Upload Build to App Store Connect

#### Option A: Using Xcode (Recommended)
1. In Xcode, select "Product" → "Archive"
2. Wait for archiving to complete
3. In Organizer window, select your archive
4. Click "Distribute App"
5. Select "App Store Connect"
6. Follow the upload process

#### Option B: Using Command Line
```bash
# Build and upload using fastlane (if configured)
flutter build ios --release
# Then use Xcode to archive and upload
```

### 6. Submit for Review

1. In App Store Connect, go to your app
2. Click "TestFlight" tab to test with beta users (optional)
3. Go to "App Store" tab
4. Click "Prepare for Submission"
5. Fill in all required information:
   - Screenshots (required for all device sizes)
   - App description
   - Keywords
   - Support URL
   - Marketing URL (optional)
   - Privacy Policy URL (required)
   - App Store Review Information

### 7. Submit for Review

1. Click "Submit for Review"
2. Answer the export compliance questions
3. Confirm submission

## Required Assets

### Screenshots (Required)
You need screenshots for these device sizes:
- iPhone 6.7" (iPhone 14 Pro Max, iPhone 15 Pro Max)
- iPhone 6.5" (iPhone 11 Pro Max, iPhone 12 Pro Max, iPhone 13 Pro Max)
- iPhone 5.5" (iPhone 8 Plus, iPhone 7 Plus, iPhone 6s Plus)
- iPad Pro 12.9" (6th generation)
- iPad Pro 12.9" (5th generation)

### App Icon
- Ensure your app icon is properly configured in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Common Issues and Solutions

### 1. Code Signing Issues
- Ensure your Apple Developer account is active
- Check that the bundle identifier matches exactly
- Verify your provisioning profiles are up to date

### 2. Build Errors
- Run `flutter clean` and `flutter pub get`
- Check that all dependencies are compatible with iOS
- Ensure minimum iOS version is set correctly (currently 12.0)

### 3. App Store Rejection
- Read Apple's [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- Ensure your app doesn't violate any policies
- Test thoroughly before submission

## Testing Before Release

1. **TestFlight Testing** (Recommended)
   - Upload build to TestFlight
   - Test with internal and external testers
   - Fix any issues before App Store submission

2. **Device Testing**
   - Test on multiple iOS devices
   - Test on different iOS versions
   - Ensure all features work correctly

## Post-Release

1. **Monitor Analytics**
   - Use App Store Connect analytics
   - Monitor crash reports
   - Track user engagement

2. **User Feedback**
   - Monitor App Store reviews
   - Respond to user feedback
   - Plan updates based on feedback

## Next Steps

1. **Marketing**
   - Prepare marketing materials
   - Plan launch strategy
   - Consider ASO (App Store Optimization)

2. **Support**
   - Set up customer support
   - Create FAQ/documentation
   - Plan for user onboarding

## Important Notes

- **Review Time**: App Store review typically takes 24-48 hours
- **Rejections**: If rejected, Apple will provide specific reasons
- **Updates**: Plan for regular updates to maintain app quality
- **Compliance**: Ensure compliance with Apple's guidelines

## Contact Information

For technical support during the release process:
- Apple Developer Support: [developer.apple.com/support](https://developer.apple.com/support)
- Flutter Documentation: [flutter.dev/docs](https://flutter.dev/docs)

---

**Good luck with your iOS release! 🚀** 