import Foundation

public class User {

    static public func tryLogin(authCode: String) -> UserInfo? {
        try? login(authCode: authCode)
    }

    static private func login(authCode: String) throws -> UserInfo {
        let cmd: LegendaryCommand = .authWithCode(authCode)
        let runner = LegendaryRunner()
        let result = try runner.run(cmd)

        if result.standardError.contains("ERROR: Logging in") {
            throw UserError.loginFailed(result.standardError)
        }

        if !result.success {
            throw UserError.commandExecutionFailed(result.standardError)
        }

        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: legendaryUserInfo())
            return try decoder.decode(UserInfo.self, from: data)
        }
        catch {
            throw UserError.userInfoCorrupted(legendaryUserInfo().path)
        }
    }
}

public enum UserError: Error, CustomStringConvertible {
    case loginFailed(String)
    case commandExecutionFailed(String)
    case userInfoCorrupted(String)

    public var description: String {
        switch self {
        case .loginFailed(let reason):
            return "Login failed: \(reason)"
        case .commandExecutionFailed(let error):
            return "Command execution failed: \(error)"
        case .userInfoCorrupted(let path):
            return "User info file corrupted at: \(path)"
        }
    }
}
