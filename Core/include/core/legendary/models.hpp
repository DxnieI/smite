#pragma once
#include <string>
#include <vector>
#include <map>
#include <optional>
#include <glaze/glaze.hpp>

namespace smite {

enum class LegendaryInstallPlatform {
    Windows,
    Win32,
    Mac,
    Android,
    iOS
};

struct Prerequisite {
    std::string args;
    std::vector<std::string> ids;
    std::string name;
    std::string path;
};

struct CustomAttributeValue {
    std::string type;
    std::string value;
};

struct KeyImage {
    int height;
    std::string md5;
    int size;
    std::string type;
    std::string uploadedDate;
    std::string url;
    int width;
    std::optional<std::string> alt;
};

struct Category {
    std::string path;
};

struct ReleaseInfo {
    std::string appId;
    std::string id;
    std::optional<std::vector<std::string>> platform;
    std::optional<std::string> dateAdded;
};

// Forward declaration for recursive type
struct GameMetadataInner;

struct MainGameItem {
    std::string id;
    std::string namespace_;
    bool unsearchable;
};

struct AssetInfo {
    std::string appName;
    std::string assetId;
    std::string buildVersion;
    std::string catalogItemId;
    std::string labelName;
    glz::raw_json metadata; 
    std::string namespace_;
    int sidecarRev;
};

struct GameMetadataInner {
    std::optional<glz::raw_json> ageGatings;
    std::optional<std::string> applicationId;
    std::optional<std::vector<Category>> categories;
    std::optional<std::string> creationDate;
    std::optional<std::map<std::string, CustomAttributeValue>> customAttributes;
    std::optional<std::string> description;
    std::optional<std::string> developer;
    std::optional<std::string> developerId;
    std::optional<std::vector<GameMetadataInner>> dlcItemList;
    std::optional<bool> endOfSupport;
    std::optional<std::string> entitlementName;
    std::optional<std::string> entitlementType;
    std::optional<std::vector<std::string>> eulaIds;
    std::optional<std::string> id;
    std::optional<std::string> itemType;
    std::optional<std::vector<KeyImage>> keyImages;
    std::optional<std::string> lastModifiedDate;
    std::optional<MainGameItem> mainGameItem;
    std::optional<std::vector<MainGameItem>> mainGameItemList;
    std::optional<std::string> shortDescription;
    std::optional<std::string> namespace_;
    std::optional<std::vector<ReleaseInfo>> releaseInfo;
    std::optional<bool> requiresSecureAccount;
    std::optional<bool> selfRefundable;
    std::optional<std::string> status;
    std::optional<std::string> technicalDetails;
    std::optional<std::string> title;
    std::optional<bool> unsearchable;
    std::optional<int> useCount;
};

struct GameMetadata {
    std::string appName;
    std::string appTitle;
    std::map<std::string, AssetInfo> assetInfos;
    std::vector<std::string> baseUrls;
    GameMetadataInner metadata;
    glz::raw_json sidecar;
};

struct InstalledJsonMetadata {
    std::string appName;
    std::vector<std::string> baseUrls;
    bool canRunOffline;
    std::string eglGuid;
    std::string executable;
    std::string installPath;
    int64_t installSize;
    std::vector<std::string> installTags;
    bool isDlc;
    std::string launchParameters;
    std::optional<std::string> manifestPath;
    bool needsVerification;
    LegendaryInstallPlatform platform;
    std::vector<Prerequisite> prereqInfo;
    bool requiresOt;
    std::optional<std::string> savePath;
    std::string title;
    std::string version;
};

struct DLCInfo {
    std::string appName;
    std::string title;
    std::optional<bool> isInstalled;
};

struct LaunchOption {
    std::string name;
    std::string parameters;
};

struct TagInfo {
    std::string tag;
    int count;
    int64_t size;
};

struct GameManifest {
    std::string appName;
    std::string buildId;
    std::string buildVersion;
    int64_t diskSize;
    int64_t downloadSize;
    int featureLevel;
    std::vector<std::string> installTags;
    std::string launchCommand;
    std::string launchExe;
    int numChunks;
    int numFiles;
    std::optional<Prerequisite> prerequisites;
    int64_t size;
    std::vector<TagInfo> tagDiskSize;
    std::vector<TagInfo> tagDownloadSize;
    std::string type;
    int version;
};

struct GameInstallInfo {
    std::string appName;
    std::optional<std::string> cloudSaveFolder;
    std::optional<std::string> cloudSaveFolderMac;
    bool cloudSavesSupported;
    std::string externalActivation;
    bool isDlc;
    std::vector<LaunchOption> launchOptions;
    std::vector<DLCInfo> ownedDlc;
    std::map<std::string, std::string> platformVersions;
    std::string title;
    std::string version;
};

struct LegendaryInstallInfo {
    GameInstallInfo game;
    GameManifest manifest;
};

struct SelectiveDownload {
    std::vector<std::string> tags;
    std::string name;
    std::string description;
    std::optional<bool> required;
};

struct GameOverride {
    std::map<std::string, std::map<std::string, std::string>> executableOverride;
    std::map<std::string, std::vector<std::string>> reorderOptimization;
    std::map<std::string, int> sdlConfig;
};

struct LegendaryConfig {
    bool webviewKillswitch;
};

struct ResponseDataLegendaryAPI {
    glz::raw_json eglConfig;
    GameOverride gameOverrides;
    LegendaryConfig legendaryConfig;
    std::vector<glz::raw_json> runtimes;
};

} // namespace smite

// Glaze meta definitions
namespace glz {
    template<>
    struct meta<smite::LegendaryInstallPlatform> {
        using enum smite::LegendaryInstallPlatform;
        static constexpr auto value = enumerate(
            "Windows", Windows,
            "Win32", smite::LegendaryInstallPlatform::Win32,
            "Mac", smite::LegendaryInstallPlatform::Mac,
            "Android", smite::LegendaryInstallPlatform::Android,
            "iOS", smite::LegendaryInstallPlatform::iOS
        );
    };

    template<>
    struct meta<smite::Prerequisite> {
        using T = smite::Prerequisite;
        static constexpr auto value = object(
            "args", &T::args,
            "ids", &T::ids,
            "name", &T::name,
            "path", &T::path
        );
    };

    template<>
    struct meta<smite::CustomAttributeValue> {
        using T = smite::CustomAttributeValue;
        static constexpr auto value = object(
            "type", &T::type,
            "value", &T::value
        );
    };

    template<>
    struct meta<smite::KeyImage> {
        using T = smite::KeyImage;
        static constexpr auto value = object(
            "height", &T::height,
            "md5", &T::md5,
            "size", &T::size,
            "type", &T::type,
            "uploadedDate", &T::uploadedDate,
            "url", &T::url,
            "width", &T::width,
            "alt", &T::alt
        );
    };

    template<>
    struct meta<smite::Category> {
        using T = smite::Category;
        static constexpr auto value = object("path", &T::path);
    };

    template<>
    struct meta<smite::ReleaseInfo> {
        using T = smite::ReleaseInfo;
        static constexpr auto value = object(
            "appId", &T::appId,
            "id", &T::id,
            "platform", &T::platform,
            "dateAdded", &T::dateAdded
        );
    };

    template<>
    struct meta<smite::MainGameItem> {
        using T = smite::MainGameItem;
        static constexpr auto value = object(
            "id", &T::id,
            "namespace", &T::namespace_,
            "unsearchable", &T::unsearchable
        );
    };

    template<>
    struct meta<smite::AssetInfo> {
        using T = smite::AssetInfo;
        static constexpr auto value = object(
            "app_name", &T::appName,
            "asset_id", &T::assetId,
            "build_version", &T::buildVersion,
            "catalog_item_id", &T::catalogItemId,
            "label_name", &T::labelName,
            "metadata", &T::metadata,
            "namespace", &T::namespace_,
            "sidecar_rev", &T::sidecarRev
        );
    };

    template<>
    struct meta<smite::GameMetadataInner> {
        using T = smite::GameMetadataInner;
        static constexpr auto value = object(
            "ageGatings", &T::ageGatings,
            "applicationId", &T::applicationId,
            "categories", &T::categories,
            "creationDate", &T::creationDate,
            "customAttributes", &T::customAttributes,
            "description", &T::description,
            "developer", &T::developer,
            "developerId", &T::developerId,
            "dlcItemList", &T::dlcItemList,
            "endOfSupport", &T::endOfSupport,
            "entitlementName", &T::entitlementName,
            "entitlementType", &T::entitlementType,
            "eulaIds", &T::eulaIds,
            "id", &T::id,
            "itemType", &T::itemType,
            "keyImages", &T::keyImages,
            "lastModifiedDate", &T::lastModifiedDate,
            "mainGameItem", &T::mainGameItem,
            "mainGameItemList", &T::mainGameItemList,
            "shortDescription", &T::shortDescription,
            "namespace", &T::namespace_,
            "releaseInfo", &T::releaseInfo,
            "requiresSecureAccount", &T::requiresSecureAccount,
            "selfRefundable", &T::selfRefundable,
            "status", &T::status,
            "technicalDetails", &T::technicalDetails,
            "title", &T::title,
            "unsearchable", &T::unsearchable,
            "useCount", &T::useCount
        );
    };

    template<>
    struct meta<smite::GameMetadata> {
        using T = smite::GameMetadata;
        static constexpr auto value = object(
            "app_name", &T::appName,
            "app_title", &T::appTitle,
            "asset_infos", &T::assetInfos,
            "base_urls", &T::baseUrls,
            "metadata", &T::metadata,
            "sidecar", &T::sidecar
        );
    };

    template<>
    struct meta<smite::InstalledJsonMetadata> {
        using T = smite::InstalledJsonMetadata;
        static constexpr auto value = object(
            "app_name", &T::appName,
            "base_urls", &T::baseUrls,
            "can_run_offline", &T::canRunOffline,
            "egl_guid", &T::eglGuid,
            "executable", &T::executable,
            "install_path", &T::installPath,
            "install_size", &T::installSize,
            "install_tags", &T::installTags,
            "is_dlc", &T::isDlc,
            "launch_parameters", &T::launchParameters,
            "manifest_path", &T::manifestPath,
            "needs_verification", &T::needsVerification,
            "platform", &T::platform,
            "prereq_info", &T::prereqInfo,
            "requires_ot", &T::requiresOt,
            "save_path", &T::savePath,
            "title", &T::title,
            "version", &T::version
        );
    };

    template<>
    struct meta<smite::DLCInfo> {
        using T = smite::DLCInfo;
        static constexpr auto value = object(
            "app_name", &T::appName,
            "title", &T::title,
            "is_installed", &T::isInstalled
        );
    };

    template<>
    struct meta<smite::LaunchOption> {
        using T = smite::LaunchOption;
        static constexpr auto value = object(
            "name", &T::name,
            "parameters", &T::parameters
        );
    };

    template<>
    struct meta<smite::TagInfo> {
        using T = smite::TagInfo;
        static constexpr auto value = object(
            "tag", &T::tag,
            "count", &T::count,
            "size", &T::size
        );
    };

    template<>
    struct meta<smite::GameManifest> {
        using T = smite::GameManifest;
        static constexpr auto value = object(
            "app_name", &T::appName,
            "build_id", &T::buildId,
            "build_version", &T::buildVersion,
            "disk_size", &T::diskSize,
            "download_size", &T::downloadSize,
            "feature_level", &T::featureLevel,
            "install_tags", &T::installTags,
            "launch_command", &T::launchCommand,
            "launch_exe", &T::launchExe,
            "num_chunks", &T::numChunks,
            "num_files", &T::numFiles,
            "prerequisites", &T::prerequisites,
            "size", &T::size,
            "tag_disk_size", &T::tagDiskSize,
            "tag_download_size", &T::tagDownloadSize,
            "type", &T::type,
            "version", &T::version
        );
    };

    template<>
    struct meta<smite::GameInstallInfo> {
        using T = smite::GameInstallInfo;
        static constexpr auto value = object(
            "app_name", &T::appName,
            "cloud_save_folder", &T::cloudSaveFolder,
            "cloud_save_folder_mac", &T::cloudSaveFolderMac,
            "cloud_saves_supported", &T::cloudSavesSupported,
            "external_activation", &T::externalActivation,
            "is_dlc", &T::isDlc,
            "launch_options", &T::launchOptions,
            "owned_dlc", &T::ownedDlc,
            "platform_versions", &T::platformVersions,
            "title", &T::title,
            "version", &T::version
        );
    };

    template<>
    struct meta<smite::LegendaryInstallInfo> {
        using T = smite::LegendaryInstallInfo;
        static constexpr auto value = object(
            "game", &T::game,
            "manifest", &T::manifest
        );
    };

    template<>
    struct meta<smite::SelectiveDownload> {
        using T = smite::SelectiveDownload;
        static constexpr auto value = object(
            "tags", &T::tags,
            "name", &T::name,
            "description", &T::description,
            "required", &T::required
        );
    };

    template<>
    struct meta<smite::GameOverride> {
        using T = smite::GameOverride;
        static constexpr auto value = object(
            "executable_override", &T::executableOverride,
            "reorder_optimization", &T::reorderOptimization,
            "sdl_config", &T::sdlConfig
        );
    };

    template<>
    struct meta<smite::LegendaryConfig> {
        using T = smite::LegendaryConfig;
        static constexpr auto value = object(
            "webview_killswitch", &T::webviewKillswitch
        );
    };

    template<>
    struct meta<smite::ResponseDataLegendaryAPI> {
        using T = smite::ResponseDataLegendaryAPI;
        static constexpr auto value = object(
            "egl_config", &T::eglConfig,
            "game_overrides", &T::gameOverrides,
            "legendary_config", &T::legendaryConfig,
            "runtimes", &T::runtimes
        );
    };
}

