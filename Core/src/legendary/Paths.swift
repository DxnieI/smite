import Foundation

// Get app support directory
private func appFolder() -> String {
    let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    return paths[0].appendingPathComponent("Smite").path
}

/// Get the config path for Legendary
public func legendaryConfigPath() -> String {
    return URL(fileURLWithPath: appFolder())
        .appendingPathComponent("legendary")
        .path
}

public func legendaryUserInfo() -> URL {
    return URL(fileURLWithPath: legendaryConfigPath())
        .appendingPathComponent("user.json")
}

func legendaryInstalled() -> URL {
    return URL(fileURLWithPath: legendaryConfigPath())
        .appendingPathComponent("installed.json")
}

func legendaryMetadata() -> String {
    return URL(fileURLWithPath: legendaryConfigPath())
        .appendingPathComponent("metadata")
        .path
}

/// Get the path to the legendary binary
public func legendaryBinaryPath() -> String {
    #if os(macOS)
        // macOS: Inside the .app bundle at Contents/Resources/bin
        if let bundlePath = Bundle.main.resourcePath {
            return URL(fileURLWithPath: bundlePath)
                .appendingPathComponent("bin")
                .appendingPathComponent("legendary")
                .path
        }
    #else
        // Windows/Linux: In bin subdirectory next to the executable
        if let executablePath = Bundle.main.executablePath {
            return URL(fileURLWithPath: executablePath)
                .deletingLastPathComponent()
                .appendingPathComponent("bin")
                .appendingPathComponent("legendary")
                .path
        }
    #endif

    // Fallback
    return "legendary"
}
