import Foundation

// MARK: - Command Result

public struct CommandResult {
    public let standardOutput: String
    public let standardError: String
    public let exitCode: Int32
    public let command: String
    public let processID: Int32

    public var success: Bool {
        exitCode == 0
    }

    public init(
        standardOutput: String,
        standardError: String,
        exitCode: Int32,
        command: String,
        processID: Int32
    ) {
        self.standardOutput = standardOutput
        self.standardError = standardError
        self.exitCode = exitCode
        self.command = command
        self.processID = processID
    }
}

// MARK: - Runner Options

public struct RunnerOptions {
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

    public init() {
        self.environment = nil
        self.workingDirectory = nil
        self.outputLimit = 1024 * 1024
        self.logOutput = false
    }
}

// MARK: - Legendary Runner

/// Runner for executing Legendary CLI commands synchronously
public class LegendaryRunner {
    private let legendaryPath: String
    private let configPath: String?

    // /// Initialize with custom path or use default
    // public init(legendaryPath: String? = nil, configPath: String? = nil) {
    //     self.legendaryPath = legendaryPath ?? Self.findLegendaryBinary()
    //     self.configPath = configPath
    // }

    public init(legendaryPath: String) {
        self.legendaryPath = legendaryPath
        self.configPath = nil
    }
    // MARK: - Public API

    /// Run a Legendary command synchronously and return Result
    public func run(
        _ command: LegendaryCommand,
        baseOptions: BaseCommandOptions = BaseCommandOptions(),
        options: RunnerOptions = RunnerOptions()
    ) throws -> CommandResult {
        let args = command.toArguments(withBase: baseOptions)
        let fullCommand = ([legendaryPath] + args).joined(separator: " ")

        if options.logOutput {
            print("🚀 Running: legendary \(args.joined(separator: " "))")
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: legendaryPath)
        process.arguments = args

        // Set up environment
        var env = ProcessInfo.processInfo.environment
        if let customEnv = options.environment {
            for (key, value) in customEnv {
                env[key] = value
            }
        }

        // Add LEGENDARY_CONFIG_PATH if provided
        if let configPath = configPath ?? Self.legendaryConfigPath() {
            env["LEGENDARY_CONFIG_PATH"] = configPath
        }
        process.environment = env

        // Set working directory if provided
        if let workingDir = options.workingDirectory {
            process.currentDirectoryURL = URL(fileURLWithPath: workingDir)
        }

        // Set up pipes for stdout and stderr
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        // Launch the process
        do {
            try process.run()
        } catch {
            throw LegendaryError.commandFailed(
                exitCode: -1,
                stderr: "Failed to launch process: \(error.localizedDescription)"
            )
        }

        // Read output (blocking)
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        // Wait for process to finish
        process.waitUntilExit()

        // Convert output to strings with limit
        var stdoutString = String(data: stdoutData, encoding: .utf8) ?? ""
        var stderrString = String(data: stderrData, encoding: .utf8) ?? ""

        if options.outputLimit > 0 {
            if stdoutString.utf8.count > options.outputLimit {
                let index = stdoutString.utf8.index(
                    stdoutString.utf8.startIndex,
                    offsetBy: options.outputLimit
                )
                stdoutString = String(stdoutString.utf8[..<index]) ?? ""
            }
            if stderrString.utf8.count > options.outputLimit {
                let index = stderrString.utf8.index(
                    stderrString.utf8.startIndex,
                    offsetBy: options.outputLimit
                )
                stderrString = String(stderrString.utf8[..<index]) ?? ""
            }
        }

        if options.logOutput {
            if !stdoutString.isEmpty {
                print("📤 stdout:", stdoutString)
            }
            if !stderrString.isEmpty {
                print("⚠️ stderr:", stderrString)
            }
            print("✅ Exit code:", process.terminationStatus)
        }

        return CommandResult(
            standardOutput: stdoutString,
            standardError: stderrString,
            exitCode: process.terminationStatus,
            command: fullCommand,
            processID: process.processIdentifier
        )
    }

    public func tryRun(
        _ command: LegendaryCommand,
        baseOptions: BaseCommandOptions = BaseCommandOptions(),
        options: RunnerOptions = RunnerOptions()
    ) -> CommandResult? {
        return try? run(command, baseOptions: baseOptions, options: options)
    }

    public func tryRun(
        _ command: LegendaryCommand,
    ) -> CommandResult? {
        return try? run(command, baseOptions: BaseCommandOptions(), options: RunnerOptions())
    }

    // MARK: - Helper Methods

    /// Find the Legendary binary using PATH
    private static func findLegendaryBinary() -> String {
        return "legendary"
    }

    /// Get the config path for Legendary
    private static func legendaryConfigPath() -> String? {
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
