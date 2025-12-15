# rive-splash-screen

Native SplashScreen with Rive animation for Capacitor apps.

## Install

```bash
npm install rive-splash-screen
npx cap sync
```

## Configuration

### capacitor.config.ts

```typescript
const config: CapacitorConfig = {
  plugins: {
    RiveSplashScreen: {
      assetName: 'splash_anim', // Name of your .riv file (without extension)
      fit: 'cover',             // Optional: cover, contain, fill, fitWidth, fitHeight, none, scaleDown, layout
    },
  },
};
```

### iOS Setup

For iOS, you need to configure the `AppDelegate.swift` to show the splash screen immediately at app launch. This eliminates the white flash that can occur when the WebView loads.

#### 1. Add the Rive animation file

Place your `.riv` file in your app's assets. The file should be accessible at `public/your_animation_name.riv` after Capacitor sync.

#### 2. Modify `AppDelegate.swift`

```swift
import UIKit
import Capacitor
import RiveRuntime              // Add this import
import RiveSplashScreenPlugin   // Add this import

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // ... existing Capacitor code ...

        // Add this BEFORE the return statement
        RiveSplashHelper.show(
            in: self.window,
            assetName: "public/splash_anim"  // Adjust to match your .riv file path
        )

        return true
    }

    // ... rest of your AppDelegate code ...
}
```

#### RiveSplashHelper.show() Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `window` | `UIWindow?` | - | The main application window |
| `assetName` | `String` | - | Path to the .riv file (e.g., `"public/splash_anim"`) |
| `fit` | `RiveFit` | `.cover` | How the animation fits in the view |
| `backgroundColor` | `UIColor` | `.white` | Background color of the splash view |

#### Available `fit` values

- `.cover` - Scale to fill, maintaining aspect ratio (may crop)
- `.contain` - Scale to fit inside, maintaining aspect ratio
- `.fill` - Stretch to fill (may distort)
- `.fitWidth` - Scale to fit width
- `.fitHeight` - Scale to fit height
- `.noFit` - No scaling
- `.scaleDown` - Scale down only if needed
- `.layout` - Use Rive layout

#### Alternative: Using String for fit

If you prefer to use a string for the fit parameter (useful for configuration):

```swift
RiveSplashHelper.show(
    in: self.window,
    assetName: "public/splash_anim",
    fitString: "cover"
)
```

### Android Setup

*Android documentation coming soon.*

## API

### hide(options?)

Hides the splash screen with an optional fade-out animation.

```typescript
import { RiveSplashScreen } from 'rive-splash-screen';

// Hide with default fade duration (400ms)
await RiveSplashScreen.hide();

// Hide with custom fade duration
await RiveSplashScreen.hide({ fadeDuration: 200 });
```

#### Options

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `fadeDuration` | `number` | `400` | Fade-out duration in milliseconds |

## How It Works

### Architecture

1. **App Launch**: `AppDelegate.didFinishLaunchingWithOptions` is called
2. **Splash Displayed**: `RiveSplashHelper.show()` adds the Rive view directly to the `UIWindow`
3. **Capacitor Loads**: The WebView loads in the background (hidden behind the splash)
4. **App Ready**: Your JavaScript calls `RiveSplashScreen.hide()`
5. **Fade Out**: The splash fades out and resources are cleaned up

This architecture eliminates the white flash because the splash is attached to the `UIWindow` before Capacitor even begins initializing the WebView.

## Example Usage

```typescript
import { RiveSplashScreen } from 'rive-splash-screen';

// In your app initialization (e.g., after data is loaded)
async function initializeApp() {
  // Load your data, authenticate user, etc.
  await loadInitialData();

  // Hide the splash screen
  await RiveSplashScreen.hide({ fadeDuration: 300 });
}
```

## Troubleshooting

### White flash still appears on iOS

Make sure you're calling `RiveSplashHelper.show()` **before** the `return true` statement in your `AppDelegate.swift`.

### Animation not showing

1. Verify the `.riv` file path is correct
2. Check that the file is included in your app bundle
3. Ensure `RiveRuntime` is properly installed via CocoaPods or SPM

### Animation not playing

The animation should auto-play. If it doesn't, verify your `.riv` file contains a valid animation and test it in the Rive editor.
