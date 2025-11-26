import Foundation

// MARK: - Legendary Library Manager

public class Library {
    // In-memory stores
    private var allGames: Set<String> = []
    private var installedGames: [String: Legendary.InstalledJsonMetadata] = [:]
    private var library: [String: Legendary.GameMetadata] = [:]

    public init(autoRefresh: Bool = true) {
        if autoRefresh {
            _ = refreshLegendary()
            loadGamesInAccount()
            refreshInstalled()
            _ = loadAll()
        }
    }



    // MARK: - Refresh Legendary Library (runs CLI, updates metadata)
    public func refreshLegendary() -> CommandResult? {
        let runner = LegendaryRunner()
        let cmd = LegendaryCommand.list(
            ListCommandOptions(thirdParty: true, forceRefresh: true)
        )
        return runner.tryRun(cmd)
    }

    // MARK: - Load all games in account (scan metadata dir)
    public func loadGamesInAccount() {
        allGames.removeAll()
        let metadataDir = legendaryMetadata()
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: metadataDir) else {
            return
        }
        for file in files where file.hasSuffix(".json") {
            let appName = file.replacingOccurrences(of: ".json", with: "")
            allGames.insert(appName)
        }
    }

    // MARK: - Refresh installed games (read installed.json)
    public func refreshInstalled() {
        installedGames.removeAll()
        let installedPath = legendaryInstalled()
        guard let data = try? Data(contentsOf: installedPath) else { return }
        guard
            let arr = try? JSONDecoder().decode([Legendary.InstalledJsonMetadata].self, from: data)
        else { return }
        for entry in arr {
            installedGames[entry.appName] = entry
        }
    }

    // MARK: - Load a single game’s metadata
    public func loadFile(_ appName: String) -> Bool {
        let filePath = URL(fileURLWithPath: legendaryMetadata()).appendingPathComponent("\(appName).json")
        guard let data = try? Data(contentsOf: filePath) else { return false }
        guard let meta = try? JSONDecoder().decode(Legendary.GameMetadata.self, from: data) else {
            return false
        }
        library[appName] = meta
        return true
    }

    // MARK: - Load all games’ metadata into memory
    public func loadAll() -> [String] {
        var loaded: [String] = []
        for appName in allGames {
            if loadFile(appName) {
                loaded.append(appName)
            }
        }
        return loaded
    }

    // MARK: - List all games (returns GameInfo)
    public func getListOfGames() -> [GameInfo] {
        return library.values.map { meta in
            let appName = meta.appName
            let title = meta.appTitle
            let developer = meta.metadata.developer
            let keyImages = meta.metadata.keyImages ?? []
            let artCover = keyImages.first(where: { $0.type == "DieselGameBox" })?.url
            let artSquare =
                keyImages.first(where: { $0.type == "DieselGameBoxTall" })?.url ??
                keyImages.first(where: { $0.type == "DieselStoreFrontTall" })?.url
            let artLogo = keyImages.first(where: { $0.type == "DieselGameBoxLogo" })?.url
            let description = meta.metadata.description
            return GameInfo(
                appName: appName,
                title: title,
                developer: developer,
                artCover: artCover,
                artSquare: artSquare,
                artLogo: artLogo,
                description: description
            )
        }
    }

    // MARK: - Get game info (loads if not present)
    public func getGameInfo(_ appName: String, forceReload: Bool = false) -> GameInfo? {
        if forceReload || library[appName] == nil {
            _ = loadFile(appName)
        }
        guard let meta = library[appName] else { return nil }
        let developer = meta.metadata.developer
        let keyImages = meta.metadata.keyImages ?? []
        let artCover = keyImages.first(where: { $0.type == "DieselGameBox" })?.url
        let artSquare =
            keyImages.first(where: { $0.type == "DieselGameBoxTall" })?.url ??
            keyImages.first(where: { $0.type == "DieselStoreFrontTall" })?.url
        let artLogo = keyImages.first(where: { $0.type == "DieselGameBoxLogo" })?.url
        let description = meta.metadata.description
        return GameInfo(
            appName: meta.appName,
            title: meta.appTitle,
            developer: developer,
            artCover: artCover,
            artSquare: artSquare,
            artLogo: artLogo,
            description: description
        )
    }
}
