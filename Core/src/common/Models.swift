import Foundation

public struct UserInfo {
    let username: String
    let userID: String

    init(from user: Legendary.UserInfo) {
        self.username = user.displayName
        self.userID = user.accountID
    }
}
