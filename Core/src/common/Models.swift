import Foundation

public struct UserInfo {
    public let username: String
    public let userID: String

    init(from user: Legendary.UserInfo) {
        self.username = user.displayName
        self.userID = user.accountID
    }
}
