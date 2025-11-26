#pragma once

#include <QObject>
#include <QString>

class UserViewModel : public QObject {
  Q_OBJECT
  Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY isLoggedInChanged)
  Q_PROPERTY(QString displayName READ displayName NOTIFY displayNameChanged)
  Q_PROPERTY(QString accountId READ accountId NOTIFY accountIdChanged)
  Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
  Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
  explicit UserViewModel(QObject *parent = nullptr);

  // Property getters
  bool isLoggedIn() const { return m_isLoggedIn; }
  QString displayName() const { return m_displayName; }
  QString accountId() const { return m_accountId; }
  QString errorMessage() const { return m_errorMessage; }
  bool isLoading() const { return m_isLoading; }

  // Invokable methods for QML
  Q_INVOKABLE void login(const QString &authCode);
  Q_INVOKABLE void logout();
  Q_INVOKABLE void checkLoginStatus();
  Q_INVOKABLE void copyToClipboard(const QString &text);
  Q_INVOKABLE void clearErrorMessage();
  

Q_SIGNALS:
  void isLoggedInChanged();
  void displayNameChanged();
  void accountIdChanged();
  void errorMessageChanged();
  void isLoadingChanged();

  void loginSuccess();
  void loginFailed(const QString &error);
  void logoutSuccess();
  void logoutFailed(const QString &error);

private:
  void setIsLoggedIn(bool value);
  void setDisplayName(const QString &value);
  void setAccountId(const QString &value);
  void setErrorMessage(const QString &value);
  void setIsLoading(bool value);
  void updateUserInfo();

  bool m_isLoggedIn;
  QString m_displayName;
  QString m_accountId;
  QString m_errorMessage;
  bool m_isLoading;
};