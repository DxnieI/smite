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

func legendaryUserInfo() -> String {
    return URL(fileURLWithPath: legendaryConfigPath())
        .appendingPathComponent("user.json")
        .path
}

func legendaryInstalled() -> String {
    return URL(fileURLWithPath: legendaryConfigPath())
        .appendingPathComponent("installed.json")
        .path
}

func legendaryMetadata() -> String {
    return URL(fileURLWithPath: legendaryConfigPath())
        .appendingPathComponent("metadata")
        .path
}
