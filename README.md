# SnapIT Virtual Try-On SDK for Flutter

A high-performance, single-line integration Virtual Try-On (VTON) SDK for D2C/e-commerce platforms. Enable your customers to try on garments directly from your mobile application using their device's camera or photo library.

---

## ⚡ Integration in 1 Minute

### 1. Add Dependency
Add this to your Flutter project's `pubspec.yaml`:
```yaml
dependencies:
  snapit_sdk:
    path: ../virtual-tryon-sdk-flutter # Or use git/pub dependency
```

### 2. Launch the Try-On Flow
Import the package and call `SnapIT.launchTryOnFlow` with a single line of code:

```dart
import 'package:snapit_sdk/snapit_sdk.dart';

void openVirtualTryOn(BuildContext context) {
  SnapIT.launchTryOnFlow(
    context: context,
    apiKey: "YOUR_SMD_API_KEY",              // smd_live_...
    userId: "DEVELOPER_USER_ID",             // From your SMD console dashboard
    garmentImageUrl: "https://yourstore.com/images/shirt_102.jpg",
    productId: "sku_shirt_102_blue",         // Optional SKU tracking
    externalUserId: "consumer_myntra_77102",  // Optional customer tracking
    metadata: {                              // Optional custom payload
      "campaign": "summer_fest_2026",
      "gender": "male"
    },
    theme: SnapITTheme(
      primaryColor: const Color(0xFFFF3F6C), // Custom brand color (e.g. Myntra pink)
      fontFamily: 'Outfit',
    ),
    onSuccess: (resultImageUrl, generationId) {
      print("Try-On Completed! Result: $resultImageUrl");
      // Handle success (e.g., save preview link or show congratulations)
    },
    onFailure: (errorMessage) {
      print("Try-On Failed: $errorMessage");
    },
  );
}
```

---

## 🔐 Platform Permissions Setup

Since this SDK accesses the local device camera and photo library, you must declare these permissions in your host application:

### iOS (`ios/Runner/Info.plist`)
Add the following entries inside your `<dict>` tag:
```xml
<key>NSCameraUsageDescription</key>
<string>This app requires access to the camera to take photos for your Virtual Try-On.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires access to the photo library to pick photos for your Virtual Try-On.</string>
```

### Android (`android/app/src/main/AndroidManifest.xml`)
Add the following permissions:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

---

## 🎨 Design Theme Parameters

The `SnapITTheme` configuration allows full compatibility with your corporate design guidelines:

| Variable | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `primaryColor` | `Color` | `Color(0xFFD4FF00)` (Acid Lemon) | Highlight/action button colors & slider accent |
| `backgroundColor` | `Color` | `Color(0xFF09090B)` (Obsidian) | Background of the bottom sheet overlay / screens |
| `cardColor` | `Color` | `Color(0xFF18181B)` (Zinc-900) | Containers / Card surfaces inside the SDK sheets |
| `textColor` | `Color` | `Colors.white` | Default title and labels text color |
| `fontFamily` | `String` | System default | Custom typeface injected by your host application |
| `borderRadius` | `double` | `16.0` | Corner roundness of buttons, containers, and slider frame |
