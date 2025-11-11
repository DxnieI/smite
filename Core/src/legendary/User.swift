import Foundation

public class User {
    static public func tryLogin(authCode: String) -> LoginResult {
        do {
            let userInfo = try login(authCode: authCode)
            return .success(userInfo)
        }
        catch let error as UserError {
            return .failure(error)
        }
        catch {
            return .failure(.commandExecutionFailed(error.localizedDescription))
        }
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
            let lgInfo = try decoder.decode(Legendary.UserInfo.self, from: data)
            return UserInfo(from: lgInfo)
        }
        catch {
            throw UserError.userInfoCorrupted(legendaryUserInfo().path)
        }
    }

    static public func tryLogout() -> LogoutResult {
        do {
            try logout()
            return .success
        }
        catch let error as UserError {
            return .failure(error)
        }
        catch {
            return .failure(.logoutFailed(error.localizedDescription))
        }
    }

    static private func logout() throws {
        let cmd: LegendaryCommand = .auth(.init(delete: true))
        let runner = LegendaryRunner()
        let result = try runner.run(cmd, options: .init(logOutput: true))

        if !result.success {
            throw UserError.logoutFailed(result.standardError)
        }
    }

    static public func isLoggedIn() -> Bool {
        FileManager.default.fileExists(atPath: legendaryUserInfo().path())
    }

    static public func getUserInfo() -> UserInfoResult {
        guard isLoggedIn() else {
            return .failure(.userInfoCorrupted("User not logged in"))
        }

        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: legendaryUserInfo())
            let lgInfo = try decoder.decode(Legendary.UserInfo.self, from: data)
            let userInfo = UserInfo(from: lgInfo)
            return .success(userInfo)
        }
        catch {
            return .failure(.userInfoCorrupted(legendaryUserInfo().path))
        }
    }
}

public enum LoginResult {
    case success(UserInfo)
    case failure(UserError)
}

public enum LogoutResult {
    case success
    case failure(UserError)
}

public enum UserInfoResult {
    case success(UserInfo)
    case failure(UserError)
}

public enum UserError: Error, CustomStringConvertible {
    case loginFailed(String)
    case commandExecutionFailed(String)
    case userInfoCorrupted(String)
    case logoutFailed(String)

    public var description: String {
        switch self {
        case .loginFailed(let reason):
            return "Login failed: \(reason)"
        case .commandExecutionFailed(let error):
            return "Command execution failed: \(error)"
        case .userInfoCorrupted(let path):
            return "User info file corrupted at: \(path)"
        case .logoutFailed(let reason):
            return "Logout failed: \(reason)"
        }
    }
}
