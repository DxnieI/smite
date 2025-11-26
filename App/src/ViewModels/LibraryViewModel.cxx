#include "viewmodels/LibraryViewModel.h"
#include "viewmodels/UserViewModel.h"
#ifndef Q_MOC_RUN
#include "core/legendary/library.h"
#endif
#include <QDebug>
#include <QtConcurrent>
#include <QMetaObject>
#include <QVariantMap>

using namespace Core;

LibraryViewModel::LibraryViewModel(QObject *parent)
    : QObject(parent), 
      m_isLoading(false),
      m_wasLoggedIn(false),
      m_userViewModel(nullptr) {
    // Load existing library data quickly (no CLI refresh)
    loadLibraryFast();
}

LibraryViewModel::LibraryViewModel(UserViewModel *userViewModel, QObject *parent)
    : QObject(parent), 
      m_isLoading(false),
      m_wasLoggedIn(false),
      m_userViewModel(userViewModel) {
    
    // Connect to user view model to track login state changes
    connectToUserViewModel(userViewModel);
    
    // Load existing library data quickly (no CLI refresh)
    loadLibraryFast();
    
    // Initialize the wasLoggedIn state
    if (m_userViewModel) {
        m_wasLoggedIn = m_userViewModel->isLoggedIn();
    }
}

void LibraryViewModel::connectToUserViewModel(UserViewModel *userViewModel) {
    if (userViewModel) {
        connect(userViewModel, &UserViewModel::isLoggedInChanged,
                this, &LibraryViewModel::onUserLoginChanged);
    }
}

void LibraryViewModel::setIsLoading(bool value) {
    if (m_isLoading != value) {
        m_isLoading = value;
        Q_EMIT isLoadingChanged();
    }
}

void LibraryViewModel::setErrorMessage(const QString &value) {
    if (m_errorMessage != value) {
        m_errorMessage = value;
        Q_EMIT errorMessageChanged();
    }
}

void LibraryViewModel::setGames(const QVariantList &value) {
    if (m_games != value) {
        m_games = value;
        Q_EMIT gamesChanged();
    }
}

void LibraryViewModel::loadLibraryFast() {
    if (m_isLoading) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());

    QThreadPool::globalInstance()->start([this]() {
        // Use empty init - loads cached data without running legendary
        Core::Library library = Core::Library::init();
        auto gamesList = library.getListOfGames();

        QVariantList games;
        for (const auto &game : gamesList) {
            // Can't use QStrings in QVariantMap directly hence this conversion
            QVariantMap gameMap;
            gameMap[QStringLiteral("appName")] = QString::fromStdString((std::string)game.getAppName());
            gameMap[QStringLiteral("title")] = QString::fromStdString((std::string)game.getTitle());
            
            if (game.getDeveloper().isSome()) {
                gameMap[QStringLiteral("developer")] = QString::fromStdString((std::string)game.getDeveloper().getSome());
            } else {
                gameMap[QStringLiteral("developer")] = QString();
            }
            
            if (game.getArtSquare().isSome()) {
                gameMap[QStringLiteral("artSquare")] = QString::fromStdString((std::string)game.getArtSquare().getSome());
            } else {
                gameMap[QStringLiteral("artSquare")] = QString();
            }
            
            if (game.getArtCover().isSome()) {
                gameMap[QStringLiteral("artCover")] = QString::fromStdString((std::string)game.getArtCover().getSome());
            } else {
                gameMap[QStringLiteral("artCover")] = QString();
            }
            
            if (game.getArtLogo().isSome()) {
                gameMap[QStringLiteral("artLogo")] = QString::fromStdString((std::string)game.getArtLogo().getSome());
            } else {
                gameMap[QStringLiteral("artLogo")] = QString();
            }
            
            if (game.getDescription().isSome()) {
                gameMap[QStringLiteral("description")] = QString::fromStdString((std::string)game.getDescription().getSome());
            } else {
                gameMap[QStringLiteral("description")] = QString();
            }

            // Installation info
            gameMap[QStringLiteral("isInstalled")] = game.isInstalled();
            if (game.getInstallPath().isSome()) {
                gameMap[QStringLiteral("installPath")] = QString::fromStdString((std::string)game.getInstallPath().getSome());
            } else {
                gameMap[QStringLiteral("installPath")] = QString();
            }
            
            games.append(gameMap);
        }

        QMetaObject::invokeMethod(this, [this, games]() {
            setGames(games);
            setIsLoading(false);
        }, Qt::QueuedConnection);
    });
}

void LibraryViewModel::refreshLibrary() {
    if (m_isLoading) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());

    QThreadPool::globalInstance()->start([this]() {
        // Use init with refresh - runs legendary to update metadata
        Core::Library library = Core::Library::init(true);
        auto gamesList = library.getListOfGames();

        QVariantList games;
        for (const auto &game : gamesList) {
            QVariantMap gameMap;
            gameMap[QStringLiteral("appName")] = QString::fromStdString((std::string)game.getAppName());
            gameMap[QStringLiteral("title")] = QString::fromStdString((std::string)game.getTitle());
            
            if (game.getDeveloper().isSome()) {
                gameMap[QStringLiteral("developer")] = QString::fromStdString((std::string)game.getDeveloper().getSome());
            } else {
                gameMap[QStringLiteral("developer")] = QString();
            }
            
            if (game.getArtSquare().isSome()) {
                gameMap[QStringLiteral("artSquare")] = QString::fromStdString((std::string)game.getArtSquare().getSome());
            } else {
                gameMap[QStringLiteral("artSquare")] = QString();
            }
            
            if (game.getArtCover().isSome()) {
                gameMap[QStringLiteral("artCover")] = QString::fromStdString((std::string)game.getArtCover().getSome());
            } else {
                gameMap[QStringLiteral("artCover")] = QString();
            }
            
            if (game.getArtLogo().isSome()) {
                gameMap[QStringLiteral("artLogo")] = QString::fromStdString((std::string)game.getArtLogo().getSome());
            } else {
                gameMap[QStringLiteral("artLogo")] = QString();
            }
            
            if (game.getDescription().isSome()) {
                gameMap[QStringLiteral("description")] = QString::fromStdString((std::string)game.getDescription().getSome());
            } else {
                gameMap[QStringLiteral("description")] = QString();
            }

            // Installation info
            gameMap[QStringLiteral("isInstalled")] = game.isInstalled();
            if (game.getInstallPath().isSome()) {
                gameMap[QStringLiteral("installPath")] = QString::fromStdString((std::string)game.getInstallPath().getSome());
            } else {
                gameMap[QStringLiteral("installPath")] = QString();
            }
            
            games.append(gameMap);
        }

        QMetaObject::invokeMethod(this, [this, games]() {
            setGames(games);
            setIsLoading(false);
        }, Qt::QueuedConnection);
    });
}

void LibraryViewModel::onUserLoginChanged() {
    if (!m_userViewModel) {
        return;
    }

    bool isLoggedIn = m_userViewModel->isLoggedIn();
    
    // Only refresh if we've transitioned from NOT logged in to logged in
    if (!m_wasLoggedIn && isLoggedIn) {
        qDebug() << "User just logged in - refreshing library with CLI";
        refreshLibrary();
    } else if (m_wasLoggedIn && !isLoggedIn) {
        // User logged out - clear the library
        qDebug() << "User logged out - clearing library";
        setGames(QVariantList());
    }
    
    m_wasLoggedIn = isLoggedIn;
}

void LibraryViewModel::clearErrorMessage() {
    setErrorMessage(QString());
}
