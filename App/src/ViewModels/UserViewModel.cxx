#include "viewmodels/UserViewModel.h"
#ifndef Q_MOC_RUN
#include "core/legendary/user.h"
#endif
#include <QDebug>
#include <QtConcurrent>
#include <QMetaObject>
#include <QClipboard>
#include <QGuiApplication>

using namespace Core;

UserViewModel::UserViewModel(QObject *parent)
    : QObject(parent), 
      m_isLoggedIn(false), 
      m_isLoading(false) {
    checkLoginStatus();
}

void UserViewModel::setIsLoggedIn(bool value) {
  if (m_isLoggedIn != value) {
    m_isLoggedIn = value;
    Q_EMIT isLoggedInChanged();
  }
}

void UserViewModel::setDisplayName(const QString &value) {
  if (m_displayName != value) {
    m_displayName = value;
    Q_EMIT displayNameChanged();
  }
}

void UserViewModel::setAccountId(const QString &value) {
  if (m_accountId != value) {
    m_accountId = value;
    Q_EMIT accountIdChanged();
  }
}

void UserViewModel::setErrorMessage(const QString &value) {
  if (m_errorMessage != value) {
    m_errorMessage = value;
    Q_EMIT errorMessageChanged();
  }
}

void UserViewModel::setIsLoading(bool value) {
  if (m_isLoading != value) {
    m_isLoading = value;
    Q_EMIT isLoadingChanged();
  }
}


void UserViewModel::login(const QString &authCode) {
    if (m_isLoading) {
      return; // prevent spamming
    }

    setIsLoading(true);
    setErrorMessage(QString());

    const std::string code = authCode.toStdString();

    // Run Legendary login on a background thread
    QtConcurrent::run([this, code]() {
        Core::LoginResult result = Core::User::tryLogin(code);

        bool ok = false;
        QString errorMsg;

        // This switch stays inside the worker thread.
        switch (result) {
        case Core::LoginResult::success: {
            ok = true;
            break;
        }
        case Core::LoginResult::failure: {
            auto error = result.getFailure();
            errorMsg = QString::fromStdString((std::string)error.getDescription());
            ok = false;
            break;
        }
        }

        // Now jump back to the GUI thread with only simple types.
        QMetaObject::invokeMethod(this, [this, ok, errorMsg]() {
                if (ok) {
                    setIsLoggedIn(true);
                    updateUserInfo();
                    setIsLoading(false);
                    Q_EMIT loginSuccess();
                    qDebug() << "Login successful:" << m_displayName;
                } else {
                    setErrorMessage(errorMsg);
                    setIsLoggedIn(false);
                    setIsLoading(false);
                    Q_EMIT loginFailed(errorMsg);
                    qDebug() << "Login failed:" << errorMsg;
                }
            },
            Qt::QueuedConnection
        );
    });
}


void UserViewModel::logout() {
    if (m_isLoading) {
      return;
    }

    setIsLoading(true);
    setErrorMessage(QString());

    QtConcurrent::run([this]() {
        Core::LogoutResult result = Core::User::tryLogout();

        bool ok = false;
        QString errorMsg;

        switch (result) {
            case Core::LogoutResult::success:
                ok = true;
                break;
            case Core::LogoutResult::failure: {
                auto error = result.getFailure();
                errorMsg = QString::fromStdString((std::string)error.getDescription());
                ok = false;
                break;
            }
        }

        QMetaObject::invokeMethod(this, [this, ok, errorMsg]() {
            if (ok) {
                setDisplayName(QString());
                setAccountId(QString());
                setIsLoggedIn(false);
                setIsLoading(false);
                Q_EMIT logoutSuccess();
                qDebug() << "Logout successful";
            } else {
                setErrorMessage(errorMsg);
                setIsLoading(false);
                Q_EMIT logoutFailed(errorMsg);
                qDebug() << "Logout failed:" << errorMsg;
            }
        }, Qt::QueuedConnection);
    });
}


void UserViewModel::updateUserInfo() {
  Core::UserInfoResult result = Core::User::getUserInfo();

  switch (result) {
    case Core::UserInfoResult::success: {
        Core::UserInfo info = result.getSuccess();

        QString name = QString::fromStdString((std::string)info.getUsername());
        QString id   = QString::fromStdString((std::string)info.getUserID());

        setDisplayName(name);
        setAccountId(id);
        setErrorMessage(QString());
        qDebug() << "Loaded user info:" << name << id;
        break;
    }
    case Core::UserInfoResult::failure: {
        auto error = result.getFailure();
        QString errorMsg = QString::fromStdString((std::string)error.getDescription());
        setErrorMessage(errorMsg);
        qDebug() << "Failed to load user info:" << errorMsg;
        break;
    }
  }
}

void UserViewModel::checkLoginStatus() {
  bool loggedIn = User::isLoggedIn();
  setIsLoggedIn(loggedIn);

  if (loggedIn) {
    updateUserInfo();
  }
}

void UserViewModel::copyToClipboard(const QString &text) {
    QClipboard *clipboard = QGuiApplication::clipboard();
    if (clipboard) {
        clipboard->setText(text);
        qDebug() << "Copied to clipboard:" << text;
    } else {
        qDebug() << "Failed to access clipboard.";
    }
}

void UserViewModel::clearErrorMessage() {
  setErrorMessage(QString());
}