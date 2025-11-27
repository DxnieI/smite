import Foundation

public struct UserInfo {
    public let username: String
    public let userID: String

    init(from user: Legendary.UserInfo) {
        self.username = user.displayName
        self.userID = user.accountID
    }
}

public struct GameInfo {
    public let appName: String
    public let title: String
    public let developer: String?
    public let artCover: String?
    public let artSquare: String?
    public let artLogo: String?
    public let description: String?
    public let isInstalled: Bool
    public let installPath: String?

    public init(
        appName: String,
        title: String,
        developer: String? = nil,
        artCover: String? = nil,
        artSquare: String? = nil,
        artLogo: String? = nil,
        description: String? = nil,
        isInstalled: Bool = false,
        installPath: String? = nil
    ) {
        self.appName = appName
        self.title = title
        self.developer = developer
        self.artCover = artCover
        self.artSquare = artSquare
        self.artLogo = artLogo
        self.description = description
        self.isInstalled = isInstalled
        self.installPath = installPath
    }
}