// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RiveSplashScreen",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "RiveSplashScreen",
            targets: ["RiveSplashScreenPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0"),
        .package(url: "https://github.com/rive-app/rive-ios.git", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "RiveSplashScreenPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "RiveRuntime", package: "rive-ios")
            ],
            path: "ios/Sources/RiveSplashScreenPlugin"),
        .testTarget(
            name: "RiveSplashScreenPluginTests",
            dependencies: ["RiveSplashScreenPlugin"],
            path: "ios/Tests/RiveSplashScreenPluginTests")
    ]
)