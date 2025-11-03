/*
private import Subprocess

#if canImport(System)
    import System
#else
    import SystemPackage
#endif

/// Result of running a Legendary command
public struct CommandResult: Sendable {
    public let stdout: String
    public let stderr: String
    public let exitCode: Int32
    public let command: String
    public let processID: Int32

    public var success: Bool {
        exitCode == 0
    }

    public init(
        stdout: String,
        stderr: String,
        exitCode: Int32,
        command: String,
        processID: Int32
    ) {
        self.stdout = stdout
        self.stderr = stderr
        self.exitCode = exitCode
        self.command = command
        self.processID = processID
    }
}

/// Options for running a command
public struct RunnerOptions: Sendable {
    public var environment: [String: String]?
    public var workingDirectory: String?
    public var outputLimit: Int
    public var logOutput: Bool

    public init(
        environment: [String: String]? = nil,
        workingDirectory: String? = nil,
        outputLimit: Int = 1024 * 1024,
        logOutput: Bool = false
    ) {
        self.environment = environment
        self.workingDirectory = workingDirectory
        self.outputLimit = outputLimit
        self.logOutput = logOutput
    }
}

// MARK: - Legendary Runner

/// Runner for executing Legendary CLI commands
#warning("How will one expose to C++?")
public actor LegendaryRunner {
    private let legendaryPath: String

    /// Initialize with custom path or use default
    public init(legendaryPath: String? = nil) {
        self.legendaryPath = legendaryPath ?? Self.findLegendaryBinary()
    }

    // MARK: - Public API

    /// Run a Legendary command and collect the result
    public func run(
        _ command: LegendaryCommand,
        baseOptions: BaseCommandOptions = BaseCommandOptions(),
        options: RunnerOptions = RunnerOptions()
    ) async throws -> CommandResult {
        let args = command.toArguments(withBase: baseOptions)
        let fullCommand = ([legendaryPath] + args).joined(separator: " ")

        if options.logOutput {
            print("🚀 Running: legendary \(args.joined(separator: " "))")
        }

        // Build environment
        var env: Subprocess.Environment = .inherit
        if let customEnv = options.environment {
            // Convert to Environment.Key dictionary using string literals
            let envUpdates = customEnv.reduce(into: [:]) { dict, pair in
                dict[Subprocess.Environment.Key(rawValue: pair.key)!] = pair.value as String?
            }
            env = .inherit.updating(envUpdates)
        }

        // Add LEGENDARY_CONFIG_PATH if provided
        if let configPath = Self.legendaryConfigPath() {
            env = env.updating(["LEGENDARY_CONFIG_PATH": configPath])
        }

        // Build execution
        let executable = Subprocess.Executable.name(legendaryPath)
        let arguments = Subprocess.Arguments(args)
        let workingDir = options.workingDirectory.map { FilePath($0) }

        let result = try await Subprocess.run(
            executable,
            arguments: arguments,
            environment: env,
            workingDirectory: workingDir,
            output: .string(limit: options.outputLimit),
            error: .string(limit: options.outputLimit)
        )

        if options.logOutput {
            if let stdout = result.standardOutput, !stdout.isEmpty {
                print("📤 stdout:", stdout)
            }
            if let stderr = result.standardError, !stderr.isEmpty {
                print("⚠️ stderr:", stderr)
            }
            print("✅ Termination status:", result.terminationStatus)
        }

        // Extract exit code from termination status
        let exitCode: Int32
        switch result.terminationStatus {
        case .exited(let code):
            exitCode = code
        case .unhandledException(let code):
            exitCode = code
        }

        return CommandResult(
            stdout: result.standardOutput ?? "",
            stderr: result.standardError ?? "",
            exitCode: exitCode,
            command: fullCommand,
            processID: result.processIdentifier.value
        )
    }

    // MARK: - Helper Methods

    /// Find the Legendary binary using PATH
    private static func findLegendaryBinary() -> String {
        // Simply return "legendary" and let the system find it in PATH
        return "legendary"
    }

    /// Get the config path for Legendary
    private static func legendaryConfigPath() -> String? {
        // Will be implemented later to return custom config path
        return nil
    }
}

// MARK: - Error Types

public enum LegendaryError: Error, CustomStringConvertible {
    case commandFailed(exitCode: Int32, stderr: String)
    case binaryNotFound
    case invalidOutput(String)

    public var description: String {
        switch self {
        case .commandFailed(let code, let stderr):
            return "Command failed with exit code \(code): \(stderr)"
        case .binaryNotFound:
            return "Legendary binary not found in PATH"
        case .invalidOutput(let message):
            return "Invalid output: \(message)"
        }
    }
}
*/
