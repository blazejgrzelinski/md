# Project Configuration Instructions

## Fix "Multiple commands produce Info.plist" Error

The error occurs because Xcode is trying to generate an Info.plist automatically while also finding a custom one. Here's how to fix it:

### Option 1: Use Xcode Project Settings (Recommended)

1. **Open your project in Xcode**
2. **Select your project** in the Project Navigator (top-level "mg")
3. **Select your target** ("mg" under TARGETS)
4. **Go to the "Info" tab**
5. **Add these keys manually:**

```
NSLocationWhenInUseUsageDescription
Value: This app needs access to your location to provide location-based features and track your activities.

NSLocationAlwaysAndWhenInUseUsageDescription  
Value: This app needs access to your location to provide location-based features and track your activities.

CFBundleLocalizations
Value: Array with: en, pl, es, fr, de

CFBundleDevelopmentRegion
Value: en

NSAppTransportSecurity
Value: Dictionary with:
  NSAllowsArbitraryLoads: YES
```

### Option 2: Recreate Info.plist (Alternative)

If you prefer to keep a custom Info.plist:

1. **In Xcode**: File → New → File → Property List
2. **Name it**: `Info.plist`
3. **Add it to your target**
4. **In Build Settings**: Set "Info.plist File" to `mg/Info.plist`

### Option 3: Use Build Settings (Simplest)

1. **Select your target**
2. **Go to Build Settings**
3. **Search for "Info.plist"**
4. **Set "Generate Info.plist File" to "No"**
5. **Add the location permissions as build settings:**

```
INFOPLIST_KEY_NSLocationWhenInUseUsageDescription = "This app needs access to your location to provide location-based features and track your activities.";
INFOPLIST_KEY_NSLocationAlwaysAndWhenInUseUsageDescription = "This app needs access to your location to provide location-based features and track your activities.";
INFOPLIST_KEY_CFBundleLocalizations = "en pl es fr de";
```

## After Configuration

1. **Clean Build Folder**: Product → Clean Build Folder (⇧⌘K)
2. **Build Project**: Product → Build (⌘B)

The error should be resolved!
